import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// یک فایل انتخاب‌شده برای نمایش در فهرست.
class VibePickedFile {
  final String name;
  final int sizeBytes;
  final VoidCallback? onOpen;

  const VibePickedFile({required this.name, required this.sizeBytes, this.onOpen});
}

/// آپلود فایل — پورت `registry/ui/file-upload.tsx`.
///
/// ناحیه‌ی رهاکردن با متن فارسی، فهرست فایل‌ها با حجم فارسی و خطای «بزرگ‌تر
/// از…». در فلاتر انتخاب واقعی فایل با اپ است: پس از انتخاب، فایل‌ها را با
/// [onFiles] برگردانید و فهرست نمایشی را با [files] کنترل کنید.
///
/// ```dart
/// VibeFileUpload(
///   hint: const Text("فرمت‌های مجاز: jpg، png تا ۵ مگابایت"),
///   maxSize: 5 * 1024 * 1024,
///   files: _files,
///   onRemove: (i) => setState(() => _files.removeAt(i)),
///   onPickRequested: () => pickFiles(),
/// )
/// ```
class VibeFileUpload extends StatelessWidget {
  final List<VibePickedFile> files;
  final int? maxSize;

  /// چندفایلی؛ false یعنی فقط یکی.
  final bool multiple;
  final Widget? hint;

  /// اپ اینجا فایل‌پیکر خودش را باز می‌کند و نتیجه را به [files] می‌دهد.
  final VoidCallback? onPickRequested;
  final void Function(int index)? onRemove;
  final String? error;

  const VibeFileUpload({
    super.key,
    this.files = const [],
    this.maxSize,
    this.multiple = true,
    this.hint,
    this.onPickRequested,
    this.onRemove,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          child: GestureDetector(
            onTap: onPickRequested,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: t.input, strokeAlign: BorderSide.strokeAlignCenter),
                  color: Colors.transparent,
                ),
                child: Column(
                  children: [
                    Icon(Icons.file_upload_outlined, size: 20, color: t.mutedForeground),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        text: "فایل را این‌جا رها کنید یا ",
                        style: TextStyle(fontSize: 14, color: t.foreground),
                        children: const [
                          TextSpan(
                            text: "انتخاب کنید",
                            style: TextStyle(fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                    if (hint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: DefaultTextStyle.merge(
                          style: TextStyle(fontSize: 12, color: t.mutedForeground),
                          child: hint!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(error!, style: TextStyle(fontSize: 12, color: t.destructive)),
          ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: t.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < files.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: i < files.length - 1 ? Border(bottom: BorderSide(color: t.border)) : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            files[i].name,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            faFileSize(files[i].sizeBytes),
                            style: TextStyle(fontSize: 12, color: t.mutedForeground),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onRemove == null ? null : () => onRemove!(i),
                          child: Icon(Icons.close, size: 14, color: t.mutedForeground),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
