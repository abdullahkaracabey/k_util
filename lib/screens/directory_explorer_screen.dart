import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum SortType { name, created, modified }

class DirectoryExplorerScreen extends StatefulWidget {
  const DirectoryExplorerScreen({super.key});

  @override
  State<DirectoryExplorerScreen> createState() =>
      _DirectoryExplorerScreenState();
}

class _DirectoryExplorerScreenState extends State<DirectoryExplorerScreen> {
  bool _isLoading = true;
  Map<String, Directory?> _directories = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final directories = <String, Directory?>{};

      // Temporary Directory
      try {
        directories['Temporary'] = await getTemporaryDirectory();
      } catch (e) {
        directories['Temporary'] = null;
      }

      // Application Support Directory
      try {
        directories['Application Support'] =
            await getApplicationSupportDirectory();
      } catch (e) {
        directories['Application Support'] = null;
      }

      // Application Documents Directory
      try {
        directories['Application Documents'] =
            await getApplicationDocumentsDirectory();
      } catch (e) {
        directories['Application Documents'] = null;
      }

      // Application Cache Directory
      try {
        directories['Application Cache'] = await getApplicationCacheDirectory();
      } catch (e) {
        directories['Application Cache'] = null;
      }

      // Library Directory (iOS/macOS only)
      try {
        directories['Library'] = await getLibraryDirectory();
      } catch (e) {
        directories['Library'] = null;
      }

      // External Storage Directory (Android only)
      try {
        directories['External Storage'] = await getExternalStorageDirectory();
      } catch (e) {
        directories['External Storage'] = null;
      }

      // Downloads Directory
      try {
        directories['Downloads'] = await getDownloadsDirectory();
      } catch (e) {
        directories['Downloads'] = null;
      }

      setState(() {
        _directories = directories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDirectories,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDirectories,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _directories.length,
                  itemBuilder: (context, index) {
                    final entry = _directories.entries.elementAt(index);
                    final name = entry.key;
                    final directory = entry.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          directory != null && directory.existsSync()
                              ? Icons.folder
                              : Icons.folder_off,
                          color: directory != null && directory.existsSync()
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        title: Text(name),
                        subtitle: Text(
                          directory?.path ?? 'Not available on this platform',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: directory != null && directory.existsSync()
                            ? const Icon(Icons.chevron_right)
                            : null,
                        onTap: directory != null && directory.existsSync()
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DirectoryContentScreen(
                                      directory: directory,
                                      title: name,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}

class DirectoryContentScreen extends StatefulWidget {
  final Directory directory;
  final String title;

  const DirectoryContentScreen({
    super.key,
    required this.directory,
    required this.title,
  });

  @override
  State<DirectoryContentScreen> createState() => _DirectoryContentScreenState();
}

class _DirectoryContentScreenState extends State<DirectoryContentScreen> {
  List<FileSystemEntity> _entities = [];
  bool _isLoading = true;
  String? _error;
  SortType _sortType = SortType.name;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entities = widget.directory.listSync();
      setState(() {
        _entities = entities;
        _isLoading = false;
        _sortEntities();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _sortEntities() {
    setState(() {
      switch (_sortType) {
        case SortType.name:
          _entities.sort((a, b) {
            final comparison = a.path
                .split('/')
                .last
                .toLowerCase()
                .compareTo(b.path.split('/').last.toLowerCase());
            return _sortAscending ? comparison : -comparison;
          });
          break;
        case SortType.created:
          _entities.sort((a, b) {
            final aStat = a.statSync();
            final bStat = b.statSync();
            final comparison = aStat.changed.compareTo(bStat.changed);
            return _sortAscending ? comparison : -comparison;
          });
          break;
        case SortType.modified:
          _entities.sort((a, b) {
            final aStat = a.statSync();
            final bStat = b.statSync();
            final comparison = aStat.modified.compareTo(bStat.modified);
            return _sortAscending ? comparison : -comparison;
          });
          break;
      }
    });
  }

  void _changeSortType(SortType newType) {
    setState(() {
      if (_sortType == newType) {
        _sortAscending = !_sortAscending;
      } else {
        _sortType = newType;
        _sortAscending = true;
      }
      _sortEntities();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<SortType>(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onSelected: _changeSortType,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortType.name,
                child: Row(
                  children: [
                    Icon(
                      _sortType == SortType.name
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('İsme göre'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortType.created,
                child: Row(
                  children: [
                    Icon(
                      _sortType == SortType.created
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Oluşturma tarihine göre'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortType.modified,
                child: Row(
                  children: [
                    Icon(
                      _sortType == SortType.modified
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Değiştirme tarihine göre'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadContents,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _entities.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Bu klasör boş'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _entities.length,
                      itemBuilder: (context, index) {
                        final entity = _entities[index];
                        final isDirectory = entity is Directory;
                        final name = entity.path.split('/').last;
                        final stat = entity.statSync();

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              isDirectory
                                  ? Icons.folder
                                  : Icons.insert_drive_file,
                              color: isDirectory ? Colors.blue : Colors.grey,
                            ),
                            title: Text(name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isDirectory)
                                  Text(
                                    'Boyut: ${_formatFileSize(stat.size)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                Text(
                                  'Oluşturuldu: ${_formatDateTime(stat.changed)}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                Text(
                                  'Değiştirildi: ${_formatDateTime(stat.modified)}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            trailing: isDirectory
                                ? const Icon(Icons.chevron_right)
                                : null,
                            onTap: isDirectory
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DirectoryContentScreen(
                                          directory: entity,
                                          title: name,
                                        ),
                                      ),
                                    );
                                  }
                                : () {
                                    _showFileDetails(
                                        entity as File, name, stat);
                                  },
                          ),
                        );
                      },
                    ),
    );
  }

  void _showFileDetails(File file, String name, FileStat stat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: 'Yol', value: file.path),
              const SizedBox(height: 8),
              _DetailRow(label: 'Boyut', value: _formatFileSize(stat.size)),
              const SizedBox(height: 8),
              _DetailRow(
                  label: 'Oluşturuldu', value: _formatDateTime(stat.changed)),
              const SizedBox(height: 8),
              _DetailRow(
                  label: 'Değiştirildi', value: _formatDateTime(stat.modified)),
              const SizedBox(height: 8),
              _DetailRow(
                  label: 'Son Erişim', value: _formatDateTime(stat.accessed)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
