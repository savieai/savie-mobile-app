enum AppEventMessageType {
  text('text'),
  image('image'),
  images('images'),
  imageWithCaption('image_with_caption'),
  imagesWithCaption('images_with_caption'),
  video('video'),
  file('file'),
  fileWithCaption('file_with_caption'),
  videoWithCaption('video_with_caption'),
  voice('voice');

  const AppEventMessageType(this.key);

  final String key;
}
