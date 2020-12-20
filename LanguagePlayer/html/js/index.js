const supportedVideoFormats = ".mp4,.avi,.mkv";
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
        firstSubtitleDropzoneDescription: {
            'en': `Drop first subtitle here or click to upload (supported formats ${supportedSubtitlesFormats})`,
            'ru': `Перетащите сюда первые субтитры или нажмите, чтобы выбрать (поддерживаемые форматы ${supportedSubtitlesFormats})`,
        },
        secondSubtitleDropzoneDescription: {
            'en': `Drop second subtitle here or click to upload (supported formats ${supportedSubtitlesFormats})`,
            'ru': `Перетащите сюда вторые субтитры или нажмите, чтобы выбрать (поддерживаемые форматы ${supportedSubtitlesFormats})`,
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
    document.getElementById("firstSubtitleDropzoneDescription").textContent = l10n["firstSubtitleDropzoneDescription"][locale];
    document.getElementById("secondSubtitleDropzoneDescription").textContent = l10n["secondSubtitleDropzoneDescription"][locale];
    document.getElementById("uploadButton").setAttribute("value", l10n["uploadButton"][locale]);
    document.getElementById("cancelButton").setAttribute("value", l10n["cancelButton"][locale]);
}

$(document).ready(documentReady);

function documentReady() {
    //Close tab event
    $(window).bind('beforeunload', function (e) {
        if (isUploading) {
            var confirmationMessage = 'There are transfers in progress, navigating away will abort them.';
            (e || window.event).returnValue = confirmationMessage;     // Gecko + IE
            return confirmationMessage;                                // Webkit, Safari, Chrome etc.
        }
    });

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

        resetDropzones();
        updateUploadButton();
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
    document.getElementById("firstSubtitleInput").setAttribute("accept", supportedSubtitlesFormats);
    document.getElementById("secondSubtitleInput").setAttribute("accept", supportedSubtitlesFormats);

    document.querySelectorAll(".drop-zone__input").forEach(inputElement => {
        const dropZoneElement = inputElement.closest(".drop-zone");

        dropZoneElement.addEventListener("click", e => {
            if (isUploading == false) {
                inputElement.click();
            }
        });

        dropZoneElement.addEventListener("change", e => {
            if (inputElement.files.length) {
                let file = inputElement.files[0];
                
                if (isFreeSpaceEnough(file.size)) {
                    updateThumbnail(dropZoneElement, file);
                    updateUploadButton();
                } else {
                    alert("Not enough free space");
                    resetDropzones();
                }
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
                dropZoneElement.classList.remove("drop-zone--over");
                
                if (e.dataTransfer.files.length) {
                    let file = e.dataTransfer.files[0];
                    
                    if (isFreeSpaceEnough(file.size) == false) {
                        alert("Not enough free space");
                        return;
                    }

                    if (isAllowFile(inputElement, file)) {
                        inputElement.files = e.dataTransfer.files;
                        updateThumbnail(dropZoneElement, file);
                    } else {
                        alert("File format must be " + inputElement.accept);
                    }
                    updateUploadButton();
                }
            }
        });
    });
}

function isFreeSpaceEnough(fileSize) {
    let xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", "/freeSpace", false); // false for synchronous request
    xmlHttp.send(null);
    
    let response = xmlHttp.responseText;
    var freeBytes = parseInt(response);
    if (freeBytes == NaN) {
        freeBytes = 0;
    }
    
    let accurancy = 10 * 8 * 1024 * 1024; //10 MB
    console.log("free " + freeBytes);
    console.log("size " + (fileSize + accurancy));
    
    return freeBytes >= fileSize + accurancy;
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
    promt.hidden = true;

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

function resetDropzones() {
    document.querySelectorAll(".drop-zone__thumb").forEach(element => {
        element.remove();
    });
    document.querySelectorAll(".drop-zone__prompt").forEach(element => {
        element.hidden = false;
    });

    document.getElementById("videoInput").value = '';
    document.getElementById("firstSubtitleInput").value = '';
    document.getElementById("secondSubtitleInput").value = '';
}


