import 'dart:async';

import 'package:flutter/material.dart';

typedef AutocompleteItemBuilder<T> = Widget? Function(
  BuildContext context,
  List<T> options,
  int index,
  String? query,
);

typedef AutocompleteInputDecoration = InputDecoration? Function(
  BuildContext context,
  TextEditingController? controller,
);

class AutocompleteSearchField<T extends Object> extends StatefulWidget {
  const AutocompleteSearchField({
    required this.itemBuilder,
    this.initialValue,
    this.children,
    this.localWhere,
    this.localSearch = true,
    this.optionsTitle,
    this.textFieldDecoration,
    this.divider,
    this.searchFieldPadding,
    super.key,
    this.resultsPadding,
    this.networkSearch,
    this.floating = true,
    this.onSelected,
    this.onClear,
    this.backgroundColor,
  })  :
        // localWhere cannot be null if localSearch is true.
        assert(
          localSearch == false || localWhere != null,
          'localWhere cannot be null if localSearch is true.',
        ),
        // children cannot be null if localSearch is true.
        assert(
          localSearch == false || children != null,
          'children cannot be null if localSearch is true.',
        ),
        // networkSearch cannot be null if localSearch is false.
        assert(
          localSearch == true || networkSearch != null,
          'networkSearch cannot be null if localSearch is false.',
        );

  factory AutocompleteSearchField.floating({
    required AutocompleteItemBuilder<T> itemBuilder,
    String? initialValue,
    List<T>? children,
    bool Function(T option, String query)? localWhere,
    bool localSearch = true,
    Widget? optionsTitle,
    AutocompleteInputDecoration? textFieldDecoration,
    Widget? divider,
    EdgeInsets? searchFieldPadding,
    EdgeInsets? resultsPadding,
    Future<Iterable<T>> Function(String query)? networkSearch,
    Color? backgroundColor,
    void Function(T selection)? onSelected,
    void Function()? onClear,
  }) {
    return AutocompleteSearchField(
      itemBuilder: itemBuilder,
      initialValue: initialValue,
      children: children,
      localWhere: localWhere,
      localSearch: localSearch,
      optionsTitle: optionsTitle,
      textFieldDecoration: textFieldDecoration,
      divider: divider,
      searchFieldPadding: searchFieldPadding,
      resultsPadding: resultsPadding,
      networkSearch: networkSearch,
      backgroundColor: backgroundColor,
      onSelected: onSelected,
      onClear: onClear,
    );
  }
  factory AutocompleteSearchField.filled({
    required AutocompleteItemBuilder<T> itemBuilder,
    String? initialValue,
    List<T>? children,
    bool Function(T option, String query)? localWhere,
    bool localSearch = true,
    Widget? optionsTitle,
    AutocompleteInputDecoration? textFieldDecoration,
    Widget? divider,
    EdgeInsets? searchFieldPadding,
    EdgeInsets? resultsPadding,
    Future<Iterable<T>> Function(String query)? networkSearch,
    Color? backgroundColor,
  }) {
    return AutocompleteSearchField(
      itemBuilder: itemBuilder,
      initialValue: initialValue,
      children: children,
      localWhere: localWhere,
      localSearch: localSearch,
      optionsTitle: optionsTitle,
      textFieldDecoration: textFieldDecoration,
      divider: divider,
      searchFieldPadding: searchFieldPadding,
      resultsPadding: resultsPadding,
      networkSearch: networkSearch,
      floating: false,
      backgroundColor: backgroundColor,
    );
  }

  final String? initialValue;
  final List<T>? children;
  final bool localSearch;

  /// User can provide their own where for local search
  /// I not provided, the search will be done by name lowercase contains
  final bool Function(
    T option,
    String query,
  )? localWhere;

  final Future<Iterable<T>> Function(String query)? networkSearch;

  // Item builder
  final AutocompleteItemBuilder<T> itemBuilder;
  final Widget? optionsTitle;
  final AutocompleteInputDecoration? textFieldDecoration;
  final Widget? divider;
  final EdgeInsets? searchFieldPadding;
  final EdgeInsets? resultsPadding;
  final bool floating;

  final Color? backgroundColor;
  final void Function(T selection)? onSelected;
  final void Function()? onClear;

  @override
  State<AutocompleteSearchField<T>> createState() =>
      _AutocompleteSearchFieldState();
}

class _AutocompleteSearchFieldState<T extends Object>
    extends State<AutocompleteSearchField<T>> {
  final textController = TextEditingController();
  final textFocusNode = FocusNode();

  InputDecoration? inputDecoration;

  // The query currently being searched for. If null, there is no pending
  // request.
  String? _currentQuery;

  // The most recent options filtered
  late Iterable<T> _lastOptions = <T>[];

  late final _Debounceable<Iterable<T>?, String> _debouncedSearch;

  // If 'localSearch' is true, this function will be called to search for options locally.
  Future<Iterable<T>?> _localSearch(String query) async {
    _currentQuery = query;

    if (query.isEmpty) {
      return widget.children;
    }

    late final Iterable<T> options;
    try {
      // Use local where

      options = widget.children!.where(
        (c) => widget.localWhere!.call(
          c,
          query,
        ),
      );
    } catch (error) {
      rethrow;
    }

    // If another search happened after this one, throw away these options.
    if (_currentQuery != query) {
      return null;
    }
    // _currentQuery = null;

    return options;
  }

  @override
  void initState() {
    super.initState();

    _debouncedSearch = _debounce<Iterable<T>?, String>(
      widget.localSearch ? _localSearch : widget.networkSearch!,
    );

    if (widget.initialValue != null) {
      textController.text = widget.initialValue!;
    }

    textController.addListener(() {
      setState(() {
        inputDecoration = widget.textFieldDecoration?.call(
          context,
          textController,
        );
      });
    });

    setState(() {
      _lastOptions = widget.children ?? [];
    });
  }

  @override
  void didChangeDependencies() {
    inputDecoration = widget.textFieldDecoration?.call(
      context,
      textController,
    );
    super.didChangeDependencies();
  }

  Widget _floatingAutocomplete() {
    return LayoutBuilder(builder: (context, constraints) {
      return RawAutocomplete<T>(
        initialValue: TextEditingValue(text: widget.initialValue ?? ''),
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController controller,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
        ) {
          controller.addListener(() {
            setState(() {
              inputDecoration = widget.textFieldDecoration?.call(
                context,
                controller,
              );
            });
          });
          return Padding(
            padding: widget.searchFieldPadding ?? EdgeInsets.zero,
            child: TextFormField(
              decoration: inputDecoration?.copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.text.isEmpty ? Icons.search : Icons.close,
                  ),
                  onPressed: () {
                    controller.clear();
                    widget.onClear?.call();
                  },
                ),
              ),
              controller: controller,
              focusNode: focusNode,
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
            ),
          );
        },
        optionsBuilder: (TextEditingValue textEditingValue) async {
          final options = await _debouncedSearch(textEditingValue.text);

          if (options == null) {
            return _lastOptions;
          }
          _lastOptions = options;
          return options;
        },
        onSelected: (T selection) {
          debugPrint('You just selected $selection');
          textController.text = selection.toString();
          widget.onSelected?.call(selection);
        },
        optionsViewBuilder: (context, onSelected, options) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              width: constraints.biggest.width,
              height: 58 * options.length.toDouble(),
              color: widget.backgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.optionsTitle != null) widget.optionsTitle!,
                  Expanded(
                    child: ListView.separated(
                      padding: widget.resultsPadding ?? EdgeInsets.zero,
                      separatorBuilder: (context, index) =>
                          widget.divider ?? const Divider(),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => onSelected(options.elementAt(index)),
                          child: widget.itemBuilder(
                            context,
                            options.toList(),
                            index,
                            _currentQuery,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _filledAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: widget.searchFieldPadding ?? EdgeInsets.zero,
          child: TextFormField(
            decoration: widget.textFieldDecoration?.call(
              context,
              textController,
            ),
            controller: textController,
            focusNode: textFocusNode,
            onChanged: (value) async {
              final options = await _debouncedSearch(value);

              if (options != null) {
                setState(() {
                  _lastOptions = options;
                });
              }
            },
            onFieldSubmitted: (String value) {
              // onFieldSubmitted();
              debugPrint('You just submitted $value');
            },
          ),
        ),
        if (widget.optionsTitle != null) widget.optionsTitle!,
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: widget.resultsPadding ?? EdgeInsets.zero,
            separatorBuilder: (context, index) =>
                widget.divider ?? const Divider(),
            itemCount: _lastOptions.length,
            itemBuilder: (context, index) {
              return widget.itemBuilder(
                context,
                _lastOptions.toList(),
                index,
                _currentQuery,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.floating) {
      return _floatingAutocomplete();
    } else {
      return _filledAutocomplete();
    }
  }
}

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } catch (error) {
      if (error is _CancelException) {
        return null;
      }
      rethrow;
    }
    return function(parameter);
  };
}

// A wrapper around Timer used for debouncing.
class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(const Duration(milliseconds: 500), _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
