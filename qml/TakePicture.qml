import QtQuick 2.4
import Ubuntu.Components 1.2
import QtMultimedia 5.4

Page {
    id:pageTakePicture;

    Item {
        id:item
        width: 640
        height: 360

        Camera {
              id: camera
              imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
                      exposure {
                          exposureCompensation: -1.0
                          exposureMode: Camera.ExposurePortrait
                      }
                      flash.mode: Camera.FlashRedEyeReduction
              imageCapture {
                  onImageCaptured: {
                      // Show the preview in an Image
                      photoPreview.source = preview
                  }
              }
          }
          VideoOutput {
              source: camera
              focus : visible // to receive focus and capture key events when visible
              anchors.fill: parent
              MouseArea {
                  anchors.fill: parent;
                  onClicked: camera.imageCapture.capture();
              }
          }
          Image {
              id: photoPreview
          }

    }

    Button {
        x: item.height + units.gu(2)
        y: item.width + units.gu(2)
        id: action
        text : "Save"
        onClicked: {
            if (action.text === "Save") {
                camera.imageCapture.capture();
                action.text = "Release"
            }
            else {
                camera.imageCapture.cancelCapture();
                photoPreview.source="";
                action.text = "Save"
            }
        }
    }
}
