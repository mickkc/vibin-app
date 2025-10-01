class ShuffleState {
  bool isShuffling;

  ShuffleState({required this.isShuffling});

  factory ShuffleState.fromJson(Map<String, dynamic> json) {
    return ShuffleState(
      isShuffling: json['isShuffling'],
    );
  }
}