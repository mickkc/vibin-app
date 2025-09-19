import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:retrofit/dio.dart';

class NetworkImageWidget extends StatelessWidget {
  final Future<HttpResponse<List<int>>> imageFuture;
  final double width;
  final double height;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const NetworkImageWidget({
    super.key,
    required this.imageFuture,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: FutureBuilder<HttpResponse<List<int>>>(
          future: imageFuture,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                width: width,
                height: height,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            else if (snapshot.hasError) {
              return SizedBox(
                width: width,
                height: height,
                child: const Center(child: Icon(Icons.error)),
              );
            }

            else if (snapshot.hasData) {

              final response = snapshot.data!;

              if (response.response.statusCode == 200) {
                final bytes = response.data;
                return Image.memory(
                  Uint8List.fromList(bytes),
                  width: width,
                  height: height,
                  fit: fit,
                );
              }
              else {
                return SizedBox(
                  width: width,
                  height: height,
                  child: const Center(child: Icon(Icons.broken_image)),
                );
              }
            }

            else {
              return SizedBox(
                width: width,
                height: height,
                child: const Center(child: Icon(Icons.image_not_supported)),
              );
            }
          },
        ),
      ),
    );
  }
}