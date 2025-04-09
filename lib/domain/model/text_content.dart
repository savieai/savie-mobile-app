import 'package:flutter_quill/quill_delta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_content.freezed.dart';

@unfreezed
class TextContent with _$TextContent {
  factory TextContent.plainText({
    required String text,
  }) = PlainTextContent;

  factory TextContent.listItem({
    required String text,
    required bool isChecked,
  }) = ListItemContent;

  static List<TextContent> fromDelta(Delta delta) {
    final List<TextContent> contents = <TextContent>[];
    String buffer = '';

    for (final Operation op in delta.toList()) {
      // Skip non-string data for simplicity
      if (op.data is! String) {
        continue;
      }

      final String text = op.data! as String;
      final Map<String, dynamic>? attributes = op.attributes;

      if (attributes != null && attributes.containsKey('list')) {
        // It's a list item
        final String listType = attributes['list'] as String;
        final bool isChecked = (listType == 'checked');

        // Combine any leftover buffer text with this operation's text
        final String combinedText = buffer + text;
        // Strip out a trailing newline if it exists (the block attribute uses it)
        final String strippedText =
            combinedText.replaceFirst(RegExp(r'\n$'), '');

        contents.add(TextContent.listItem(
          text: strippedText,
          isChecked: isChecked,
        ));

        buffer = ''; // Reset the buffer
      } else {
        // Plain text
        if (text.contains('\n')) {
          // Split on newlines
          final List<String> parts = text.split('\n');
          for (int i = 0; i < parts.length; i++) {
            final String part = parts[i];
            if (i < parts.length - 1) {
              // Each part before the last in this chunk is a full line (with a \n).
              contents.add(TextContent.plainText(text: '$buffer$part\n'));
              buffer = ''; // reset buffer
            } else {
              // The last part doesn't have a trailing \n
              buffer += part;
            }
          }
        } else {
          // Accumulate in buffer
          buffer += text;
        }
      }
    }

    // If there's leftover text in buffer, it's plain text
    if (buffer.isNotEmpty) {
      contents.add(TextContent.plainText(text: buffer));
    }

    return contents;
  }

  static Delta toDelta(List<TextContent> contents) {
    final Delta delta = Delta();

    for (final TextContent content in contents) {
      content.when(
        plainText: (String text) {
          // Insert the plain text.
          delta.insert(text);
        },
        listItem: (String text, bool isChecked) {
          // First, insert the list item's text (without a newline).
          delta.insert(text);
          // Then, insert a newline with the proper 'list' attribute
          // to mark it as a checked or unchecked list item.
          delta.insert('\n', <String, dynamic>{
            'list': isChecked ? 'checked' : 'unchecked',
          });
        },
      );
    }

    if (delta.isEmpty) {
      delta.insert('\n');
    }

    return delta;
  }
}
