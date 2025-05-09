import 'package:flutter_quill/quill_delta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_content.freezed.dart';

@freezed
class TextContent with _$TextContent {
  const TextContent._();

  const factory TextContent.plainText({
    required String text,
  }) = PlainTextContent;

  const factory TextContent.listItem({
    required String text,
    required bool isChecked,
  }) = ListItemContent;

  static List<TextContent> fromDelta(Delta delta) {
    final List<TextContent> contents = <TextContent>[];
    String buffer = '';
    bool isPreviousList = false;
    bool hasList = false;
    List<Operation> ops = delta.operations.toList();
    
    // First pass: detect if this delta contains a list
    for (final op in ops) {
      if (op.attributes != null && op.attributes!.containsKey('list')) {
        hasList = true;
        break;
      }
    }
    
    // Second pass: process the operations
    for (int i = 0; i < ops.length; i++) {
      final Operation op = ops[i];
      
      // Skip non-string data for simplicity
      if (op.data is! String) {
        continue;
      }

      final String text = op.data! as String;
      final Map<String, dynamic>? attributes = op.attributes;

      if (attributes != null && attributes.containsKey('list')) {
        isPreviousList = true;
        // It's a list item
        final String listType = attributes['list'] as String;
        final bool isChecked = (listType == 'checked');

        // Combine any leftover buffer text with this operation's text
        String combinedText = buffer + text;
        // Strip out a trailing newline if it exists (the block attribute uses it)
        final String strippedText =
            combinedText.replaceFirst(RegExp(r'\n$'), '');

        contents.add(TextContent.listItem(
          text: strippedText,
          isChecked: isChecked,
        ));

        buffer = ''; // Reset the buffer
      } else {
        // Special handling for what might be a list item without proper attributes
        if (hasList) {
          // If we're in a list context, this could be a list item missing attributes
          
          // Case 1: A newline right after a list item but with missing attributes
          if (isPreviousList && text == '\n') {
            // Skip this operation as we've included the newline in the previous item
            isPreviousList = false;
            continue;
          }
          
          // Case 2: Text at the end of the delta that should be part of the list
          // If this is the last or second-to-last operation, and we've seen list items before
          if ((i == ops.length - 1 || i == ops.length - 2) && 
              text.trim().isNotEmpty &&
              contents.isNotEmpty && 
              contents.last is ListItemContent) {
              
            // Check if the next op is just a newline (common pattern)
            bool isFollowedByNewline = i < ops.length - 1 && 
                ops[i+1].isInsert && 
                ops[i+1].data is String && 
                (ops[i+1].data as String) == '\n';
                
            // This is likely a list item that lost its attributes during enhancement
            contents.add(TextContent.listItem(
              text: text.replaceFirst(RegExp(r'\n$'), ''),
              isChecked: false,  // Default to unchecked for safety
            ));
            
            // Skip the next operation if it's just a newline
            if (isFollowedByNewline) {
              i++;
            }
            
            buffer = '';
            continue;
          }
        }
        
        // Regular plain text handling
        if (text.contains('\n')) {
          // Split on newlines
          final List<String> parts = text.split('\n');
          for (int j = 0; j < parts.length; j++) {
            final String part = parts[j];
            if (j < parts.length - 1) {
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
        
        isPreviousList = false;
      }
    }

    // If there's leftover text in buffer, it's plain text
    if (buffer.isNotEmpty) {
      // If we're in a list context and this is leftover text, try to add it as a list item
      if (hasList && contents.isNotEmpty && contents.last is ListItemContent) {
        contents.add(TextContent.listItem(
          text: buffer,
          isChecked: false,
        ));
      } else {
        contents.add(TextContent.plainText(text: buffer));
      }
    }

    return contents;
  }

  static Delta toDelta(List<TextContent> textContents) {
    final Delta delta = Delta();
    
    for (final TextContent content in textContents) {
      if (content is PlainTextContent) {
        delta.insert(content.text);
      } else if (content is ListItemContent) {
        // Insert the text content
        delta.insert(content.text);
        
        // Add the line break with appropriate list attribute
        // This ensures all list items, including the last one, have the proper formatting
        delta.insert('\n', {
          'list': content.isChecked ? 'checked' : 'unchecked',
        });
      }
    }
    
    // If the last content is not a ListItemContent and doesn't end with a newline,
    // add a newline to ensure proper document rendering
    if (textContents.isNotEmpty && 
        textContents.last is PlainTextContent &&
        !textContents.last.text.endsWith('\n')) {
      delta.insert('\n');
    }
    
    return delta;
  }
}
