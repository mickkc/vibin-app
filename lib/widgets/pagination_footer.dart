import 'package:flutter/material.dart';

class PaginationFooter extends StatelessWidget {
  final dynamic pagination;
  final Function? onPageChanged;

  const PaginationFooter({super.key, required this.pagination, this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final pages = (pagination.total / pagination.pageSize).ceil();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: pagination.currentPage <= 1 ? null : () {
              if (onPageChanged != null) {
                onPageChanged!(pagination.currentPage - 1);
              }
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text("${pagination.currentPage} / $pages"),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: pagination.currentPage >= pages ? null : () {
              if (onPageChanged != null) {
                onPageChanged!(pagination.currentPage + 1);
              }
            },
            icon: const Icon(Icons.chevron_right)
          ),
        ],
      ),
    );
  }
}