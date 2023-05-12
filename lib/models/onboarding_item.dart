class OnBoardingItem {
  String _title;
  String _image;
  // ignore: prefer_final_fields
  String _desc;

  String get image => _image;
  String get desc => _desc;
  String get title => _title;

  OnBoardingItem(
    this._title,
    this._image,
    this._desc,
  );
}
