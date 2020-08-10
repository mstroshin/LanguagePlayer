class API {
    constructor() {
        this.json = {};
        this.json.videos = [{ id: 0, title: "Video0" }, { id: 1, title: "Video1" }];
    }

    list(callback, error) {
        // this._request("GET", "/list", null, callback, error);
        callback(this.json);
    }

    remove(id, callback, error) {
        // this._request("DELETE", "/video/" + id, null, callback, error);

        this.json.videos = this.json.videos.filter(video => video.id != id);
        callback();
    }

    _request(method, url, data, callback, error) {
        $.ajax({
            method: method,
            url: url,
            data: data
        })
            .done(function (json) {
                callback(json);
            })
            .fail(function (json) {
                if (error) {
                    error(json);
                }
            });
    }
}

var api = new API();

$(document).ready(documentReady);

function documentReady() {
    configureDropzone();
    configureProgressBar();
}

function configureProgressBar() {
    const uploadForm = document.getElementById("uploadForm");

    uploadForm.addEventListener("submit", (e) => {
        e.preventDefault();
        console.log(uploadForm);

        const progressBar = document.getElementById("progressBar");

        const xhr = new XMLHttpRequest();
        xhr.open("POST", "/upload");
        xhr.upload.addEventListener("progress", (e) => {
            console.log(e);
            const percent = e.lengthComputable ? (e.loaded / e.total) * 100 : 0;
            console.log(percent);

            progressBar.style.width = percent.toFixed(0) + "%";
            progressBar.textContent = percent.toFixed(0) + "%";
        });
        xhr.send(new FormData(uploadForm));
    });
}

function configureDropzone() {
    document.querySelectorAll(".drop-zone__input").forEach(inputElement => {
        const dropZoneElement = inputElement.closest(".drop-zone");

        dropZoneElement.addEventListener("click", e => {
            inputElement.click();
        });

        dropZoneElement.addEventListener("change", e => {
            if (inputElement.files.length) {
                updateThumbnail(dropZoneElement, inputElement.files[0]);
            }
        });

        dropZoneElement.addEventListener("dragover", e => {
            e.preventDefault();
            dropZoneElement.classList.add("drop-zone--over");
        });

        ["dragleave", "dragend"].forEach(type => {
            dropZoneElement.addEventListener(type, e => {
                dropZoneElement.classList.remove("drop-zone--over");
            });
        });

        dropZoneElement.addEventListener("drop", e => {
            e.preventDefault();

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
        });
    });
}

function isAllowFile(input, file) {
    return file.name.includes(input.accept);
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
        // let blobURL = URL.createObjectURL(file);
        // let video = document.createElement("video");
        // video.src = blobURL;
        // video.currentTime = 30;
        // thumbnailElement.appendChild(video);
        let movieIcon = document.createElement("i");
        movieIcon.className = 'icon-camera-retro';
        thumbnailElement.appendChild(movieIcon);
    }
}


