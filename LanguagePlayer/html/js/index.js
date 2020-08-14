const supportedVideoFormats = ".mp4";
const supportedSubtitlesFormats = ".srt";
var isUploading = false;

$(document).ready(documentReady);

function documentReady() {
    configureDropzone();
    configureUploadForm();
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

    if (file.type.startsWith("video/")) {
        let movieIcon = document.createElement("i");
        movieIcon.className = 'icon-camera-retro';
        thumbnailElement.appendChild(movieIcon);
    }
}


