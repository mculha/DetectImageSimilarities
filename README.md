# DetectImageSimilarities

The app helps us to avoid keeping the same images in our gallery. First of all, the app scans all images in the gallery and finds similar ones by computing the distance between images.
If the user considers deleting similar ones the app helps us to delete them as well.
The documentation I have been inspired by is below [**here**](https://developer.apple.com/documentation/vision/analyzing_image_similarity_with_feature_print).

As you can see in the video, the app finds duplicate images in the gallery. Processing 3000 images takes approximately 30 seconds.
**NOTE:** None of Vision Features works in simulators. That is why we must use real devices to test it.

https://github.com/mculha/DetectImageSimilarities/assets/20414142/f7f4229f-4ab7-463d-984e-1b212212507d


