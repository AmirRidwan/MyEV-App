class ModelItem {
  final String selectedImage;
  final String image;
  final String label;

  ModelItem(this.selectedImage, this.image, this.label);

  factory ModelItem.fromJson(Map<String, dynamic> json) {
    return ModelItem(
      json['selectedImage'] ?? '',
      json['image'] ?? '',
      json['label'] ?? '',
    );
  }
}
