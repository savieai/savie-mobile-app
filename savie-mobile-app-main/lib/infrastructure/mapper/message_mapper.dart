// ignore_for_file: always_specify_types

import 'dart:convert';
import 'package:flutter_quill/quill_delta.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';
import 'link_mapper.dart';

sealed class MessageMapper {
  static Message toDomain(MessageDTO dto) {
    if (dto.voiceMessages?.firstOrNull != null) {
      return Message.audio(
        tempId: dto.tempId,
        id: dto.id,
        date: dto.createdAt.toLocal(),
        isPending: false,
        audioInfo: AudioInfo(
          name: dto.voiceMessages!.first.name,
          signedUrl: dto.voiceMessages!.first.signedUrl,
          localFullPath: null,
          messageId: dto.voiceMessages!.first.messageId,
          duration: Duration(seconds: dto.voiceMessages!.first.duration),
          peaks: dto.voiceMessages!.first.peaks,
        ),
        transcription: dto.voiceMessages!.firstOrNull?.transcriptionText,
      );
    }

    final List<FileAttachmentResponseDTO> fileDtos = dto.attachments.where(
      (FileAttachmentResponseDTO f) {
        return f.attachmentType == FileAttachmentTypeDTO.file;
      },
    ).toList();

    final List<Attachment> files =
        fileDtos.map(FileAttachmentMapper.toDomain).toList();

    if (files.isNotEmpty) {
      return FileMessage(
        tempId: dto.tempId,
        isPending: false,
        id: dto.id,
        date: dto.createdAt.toLocal(),
        file: files.first,
      );
    }

    final List<FileAttachmentResponseDTO> imageDtos = dto.attachments.where(
      (FileAttachmentResponseDTO f) {
        return f.attachmentType == FileAttachmentTypeDTO.image;
      },
    ).toList();

    final List<Attachment> images =
        imageDtos.map(FileAttachmentMapper.toDomain).toList();

    final List<Link> links = dto.links.map(LinkMapper.toDomain).toList();

    return Message.text(
      id: dto.id,
      tempId: dto.tempId,
      date: dto.createdAt.toLocal(),
      originalTextContents: dto.deltaContent == null
          ? null
          : TextContent.fromDelta(parseDelta(dto.deltaContent!)),
      images: images,
      isPending: false,
      links: links,
      improvedTextContents: dto.enhancedDeltaContent == null
          ? null
          : TextContent.fromDelta(parseDelta(dto.enhancedDeltaContent!)),
    );
  }

  static Delta parseDelta(Map<String, dynamic> deltaContent) {
    // First handle potential string response
    if (deltaContent['ops'] == null) {
      print('Warning: Delta content does not have "ops" property: $deltaContent');
      // Create a basic delta with the content as plain text
      return Delta()..insert(deltaContent.toString())..insert('\n');
    }
    
    final dynamic ops = deltaContent['ops'];
    Delta delta;
    
    try {
      if (ops is List) {
        delta = Delta.fromJson(ops as List<dynamic>);
      } else if (ops is String) {
        // Try to parse string as JSON
        try {
          delta = Delta.fromJson(jsonDecode(ops) as List<dynamic>);
        } catch (_) {
          // If parsing fails, create a simple delta
          delta = Delta()..insert(ops)..insert('\n');
        }
      } else {
        // Fallback
        delta = Delta()..insert(ops.toString())..insert('\n');
      }
    } catch (e) {
      print('Error parsing delta: $e');
      delta = Delta()..insert('\n');
    }
    
    if (delta.isEmpty) {
      return Delta()..insert('\n');
    }

    if (!(delta.last.data! as String).endsWith('\n')) {
      delta.insert('\n');
    }

    return delta;
  }

  // Add a utility function to fix delta formatting issues
  static Delta fixDeltaFormatting(Delta delta) {
    // IMPORTANT NOTE: This function fixes a critical issue with to-do list formatting
    // The problem: The last item in a to-do list might not have proper list formatting
    // when the backend generates the Delta. This causes the last checkbox to be missing
    // in the UI. This function ensures all list items have the proper formatting attributes.
    
    // First, check if this delta contains any list items
    bool hasList = false;
    Map<String, dynamic>? lastListAttributes = null;
    Delta fixedDelta = Delta();
    
    // Copy all operations from the original delta and track list attributes
    for (final op in delta.operations) {
      if (op.attributes != null && 
          op.attributes!.containsKey('list')) {
        hasList = true;
        lastListAttributes = Map<String, dynamic>.from(op.attributes!);
      }
      fixedDelta.push(op);
    }
    
    // If there are no list items, just return the original delta
    if (!hasList) {
      return delta;
    }
    
    // For lists, ensure all items have proper formatting
    // Let's do a more comprehensive fix by analyzing and rebuilding the delta if needed
    var operations = fixedDelta.operations.toList();
    bool needsRebuild = false;
    
    // Check for common problems in the delta structure that would indicate issues
    for (int i = 0; i < operations.length - 1; i++) {
      final current = operations[i];
      final next = operations[i + 1];
      
      // Case 1: Text followed by a plain newline where both should be part of a list
      if (current.isInsert && next.isInsert &&
          current.data is String && next.data is String &&
          (next.data as String) == '\n' &&
          !(current.data as String).endsWith('\n') &&
          next.attributes == null &&
          i > 0 && i < operations.length - 2) {
        
        // Check if previous operation had list attributes
        bool previousOpHadListAttrs = false;
        for (int j = i - 1; j >= 0; j--) {
          if (operations[j].attributes != null && 
              operations[j].attributes!.containsKey('list')) {
            previousOpHadListAttrs = true;
            break;
          }
        }
        
        // Check if following operations have list attributes
        bool followingOpsHaveListAttrs = false;
        for (int j = i + 2; j < operations.length; j++) {
          if (operations[j].attributes != null && 
              operations[j].attributes!.containsKey('list')) {
            followingOpsHaveListAttrs = true;
            break;
          }
        }
        
        // If both previous and following ops have list attributes, 
        // this item should also have list attributes
        if (previousOpHadListAttrs && followingOpsHaveListAttrs) {
          needsRebuild = true;
          break;
        }
      }
      
      // Case 2: Last item is missing list attribute
      if (i == operations.length - 2 && 
          current.isInsert && current.data is String && 
          next.isInsert && next.data is String && (next.data as String) == '\n' &&
          (next.attributes == null || !next.attributes!.containsKey('list')) &&
          lastListAttributes != null) {
        needsRebuild = true;
        break;
      }
    }
    
    // If we need to rebuild, let's create a properly formatted delta
    if (needsRebuild && lastListAttributes != null) {
      final rebuiltDelta = Delta();
      List<String> textParts = [];
      
      // Extract all text from the delta
      for (final op in operations) {
        if (op.isInsert && op.data is String) {
          textParts.add(op.data as String);
        }
      }
      
      // Combine all text
      final fullText = textParts.join('');
      
      // Split by newlines to get individual lines
      final lines = fullText.split('\n');
      
      // Build a new delta with proper list formatting
      bool foundListStart = false;
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Skip empty last line
        if (i == lines.length - 1 && line.isEmpty) {
          continue;
        }
        
        // Detect if this is the start of a list (first line often has no list formatting)
        if (!foundListStart && i < lines.length - 1) {
          rebuiltDelta.insert(line);
          rebuiltDelta.insert('\n');
          
          // Check next line to see if it starts a list
          for (final op in operations) {
            if (op.attributes != null && op.attributes!.containsKey('list')) {
              foundListStart = true;
              break;
            }
          }
          continue;
        }
        
        // For list items, make sure they have the proper attributes
        if (foundListStart) {
          rebuiltDelta.insert(line);
          rebuiltDelta.insert('\n', lastListAttributes);
        } else {
          // Not in a list context
          rebuiltDelta.insert(line);
          rebuiltDelta.insert('\n');
        }
      }
      
      return rebuiltDelta;
    }
    
    // Simple fix for the last item missing list formatting
    if (fixedDelta.operations.isNotEmpty && lastListAttributes != null) {
      final lastOp = fixedDelta.operations.last;
      
      // If the last operation is a newline without list attributes, add them
      if (lastOp.isInsert && 
          lastOp.data is String && 
          (lastOp.data as String) == '\n' &&
          (lastOp.attributes == null || !lastOp.attributes!.containsKey('list'))) {
        
        // Replace the last operation with one that has the proper list attribute
        fixedDelta.operations.removeLast();
        fixedDelta.insert('\n', lastListAttributes);
      }
    }
    
    return fixedDelta;
  }
}
