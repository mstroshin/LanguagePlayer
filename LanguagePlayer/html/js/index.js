const supportedVideoFormats = ".mp4,.avi";
const supportedSubtitlesFormats = ".srt";
var isUploading = false;

function localizePage() {
    const getNavigatorLanguage = () => {
        var locale = "";

        if (navigator.languages && navigator.languages.length) {
            locale = navigator.languages[0];
        } else {
            locale = navigator.userLanguage || navigator.language || navigator.browserLanguage || 'en';
        }

        return locale.substring(0, 2).toLowerCase();
    }
    var locale = getNavigatorLanguage();
    // locale = "ru";

    const l10n = {
        pageTitle: {
            'en': 'Language Player - Video Uploader',
            'ru': 'Language Player - Загрузчик Видео',
        },
        videoDropzoneDescription: {
            'en': `Drop video here or click to upload (supported formats ${supportedVideoFormats})`,
            'ru': `Перетащите сюда видео файл или нажмите, чтобы выбрать (поддерживаемые форматы ${supportedVideoFormats})`,
        },
        sourceSubtitleDropzoneDescription: {
            'en': `Drop source subtitle here or click to upload (supported formats ${supportedSubtitlesFormats})`,
            'ru': `Перетащите сюда оригинальные субтитры или нажмите, чтобы выбрать (поддерживаемые форматы ${supportedSubtitlesFormats})`,
        },
        uploadButton: {
            'en': 'Upload',
            'ru': 'Загрузить',
        },
        cancelButton: {
            'en': 'Cancel',
            'ru': 'Отменить',
        },
    };

    document.getElementById("pageTitle").textContent = l10n["pageTitle"][locale];
    document.getElementById("videoDropzoneDescription").textContent = l10n["videoDropzoneDescription"][locale];
    document.getElementById("sourceSubtitleDropzoneDescription").textContent = l10n["sourceSubtitleDropzoneDescription"][locale];
    document.getElementById("uploadButton").setAttribute("value", l10n["uploadButton"][locale]);
    document.getElementById("cancelButton").setAttribute("value", l10n["cancelButton"][locale]);
}

$(document).ready(documentReady);

function documentReady() {
    configureDropzone();
    configureUploadForm();
    localizePage();
}

function configureUploadForm() {
    const uploadForm = document.getElementById("uploadForm");
    const progressBarContainer = document.getElementById("progressBarContainer");
    const progressBar = document.getElementById("progressBar");
    const uploadButton = document.getElementById("uploadButton");
    const cancelButton = document.getElementById("cancelButton");

    const xhr = new XMLHttpRequest();

    function startedUploading() {
        isUploading = true;
        uploadButton.hidden = true;
        cancelButton.hidden = false;
        progressBarContainer.hidden = false;
    }

    function stopedUploading() {
        isUploading = false;
        uploadButton.hidden = false;
        cancelButton.hidden = true;
        progressBarContainer.hidden = true;
        progressBar.style.width = "0%";
    }

    uploadForm.addEventListener("submit", (e) => {
        e.preventDefault();

        xhr.upload.onloadstart = startedUploading;
        xhr.upload.onabort = stopedUploading;
        xhr.upload.onerror = stopedUploading;

        xhr.upload.onprogress = function (e) {
            const percent = e.lengthComputable ? (e.loaded / e.total) * 100 : 0;
            progressBar.style.width = percent.toFixed(0) + "%";
            progressBar.textContent = percent.toFixed(0) + "%";
        }
        xhr.upload.onload = function () {
            console.log("Finished!");
            stopedUploading();
            alert("Uploading is done!");
        };

        xhr.open("POST", "/upload");
        xhr.send(new FormData(uploadForm));
    });

    cancelButton.addEventListener("click", (e) => {
        e.preventDefault();
        xhr.abort();
    });
}

function configureDropzone() {
    document.getElementById("videoInput").setAttribute("accept", supportedVideoFormats);
    document.getElementById("sourceSubtitleInput").setAttribute("accept", supportedSubtitlesFormats);

    document.querySelectorAll(".drop-zone__input").forEach(inputElement => {
        const dropZoneElement = inputElement.closest(".drop-zone");

        dropZoneElement.addEventListener("click", e => {
            if (isUploading == false) {
                inputElement.click();
            }
        });

        dropZoneElement.addEventListener("change", e => {
            if (inputElement.files.length) {
                updateThumbnail(dropZoneElement, inputElement.files[0]);
                updateUploadButton();
            }
        });

        dropZoneElement.addEventListener("dragover", e => {
            e.preventDefault();
            if (isUploading == false) {
                dropZoneElement.classList.add("drop-zone--over");
            }
        });

        ["dragleave", "dragend"].forEach(type => {
            dropZoneElement.addEventListener(type, e => {
                if (isUploading == false) {
                    dropZoneElement.classList.remove("drop-zone--over");
                }
            });
        });

        dropZoneElement.addEventListener("drop", e => {
            e.preventDefault();
            if (isUploading == false) {
                if (e.dataTransfer.files.length) {
                    let file = e.dataTransfer.files[0];

                    if (isAllowFile(inputElement, file)) {
                        inputElement.files = e.dataTransfer.files;
                        updateThumbnail(dropZoneElement, file);
                    } else {
                        alert("File format must be " + inputElement.accept);
                    }
                    updateUploadButton();
                }

                dropZoneElement.classList.remove("drop-zone--over");
            }
        });
    });
}

function isAllowFile(input, file) {
    const splits = file.name.split(".");
    const format = splits[splits.length - 1];

    return input.accept.includes(format);
}

function updateUploadButton() {
    const videoInput = document.getElementById("videoInput");
    document.getElementById("uploadButton").disabled = videoInput.files[0] == null;
}

function updateThumbnail(dropZoneElement, file) {
    let thumbnailElement = dropZoneElement.querySelector(".drop-zone__thumb");

    let promt = dropZoneElement.querySelector(".drop-zone__prompt");
    if (promt) {
        promt.remove();
    }

    if (!thumbnailElement) {
        thumbnailElement = document.createElement("div");
        thumbnailElement.classList.add("drop-zone__thumb");
        dropZoneElement.appendChild(thumbnailElement);
    }
    thumbnailElement.dataset.label = file.name;

    if (thumbnailElement.querySelector(".dropzoneIcon") === null) {
        if (file.type.startsWith("video/")) {
            let movieIcon = document.createElement("img");
            movieIcon.className = "dropzoneIcon";
            movieIcon.src = "file-video-solid.svg";
            thumbnailElement.appendChild(movieIcon);
        }
        else {
            let movieIcon = document.createElement("img");
            movieIcon.className = "dropzoneIcon";
            movieIcon.src = "file-invoice-solid.svg";
            thumbnailElement.appendChild(movieIcon);
        }
    }
}


