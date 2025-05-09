# savie

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flutter Plugin Building Issues

If you encounter build errors related to Flutter plugins (such as `'Flutter/Flutter.h' file not found` or `double-quoted include in framework header`), we have implemented a permanent fix for these issues.

See [PLUGIN_FIX_README.md](./PLUGIN_FIX_README.md) for detailed information on the fix and how to apply it.

Quick steps to fix plugin issues:

```bash
# From the project root directory
./scripts/fix_flutter_plugins.sh
```
