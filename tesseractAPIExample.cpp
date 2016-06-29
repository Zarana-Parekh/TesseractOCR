#include <iostream>
#include <string>
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>

int main()
{
    std::cout << "Please enter an image filename: ";
    char* filename;
    std::cin >> filename;
    char *outText;

    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
    // Initialize tesseract-ocr with English, without specifying tessdata path
    if (api->Init(NULL, "eng")) { // specify language to be used
        fprintf(stderr, "Could not initialize tesseract.\n");
        exit(1);
    }

    // Open input image with leptonica library
    Pix *image = pixRead(filename);
    api->SetImage(image);
    api->Recognize(0);
      tesseract::ResultIterator* ri = api->GetIterator();
      tesseract::PageIteratorLevel level = tesseract::RIL_SYMBOL;
      if (ri != 0) {
        do {
          const char* word = ri->GetUTF8Text(level);
          float conf = ri->Confidence(level);
          printf("%s: %.2f\n",word, conf);
          delete[] word;
        } while (ri->Next(level));
      }

    // Destroy used object and release memory
    api->End();
    pixDestroy(&image);

    return 0;
}