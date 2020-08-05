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

function renderVideosTable() {
    api.list(function (json) {
        var tableBody = $("#tableBodyId")
        tableBody.empty();

        json.videos.forEach(video => {
            tableBody.append($('<tr>')
                .attr("id", "video-" + video.id)
                .append($('<td>')
                    .text(video.id))
                .append($('<td>')
                    .text(video.title))
                .append($('<td>')
                    .append($('<button>')
                        .attr("type", "button")
                        .attr("class", "btn btn-primary m-1 w-5")
                        .attr("onclick", "removeVideo(" + video.id + ")")
                        .append($("<i>")
                            .attr("class", "fa fa-camera-retro fa-lg")))));
        });
    });
}

function removeVideo(id) {
    api.remove(id, function () {
        $("#video-" + id).remove();
    });
}

function onSubmitUpload() {
    let uploadForm = $("#uploadForm")[0];
    // let progressBar = $("#myBar");

    var request = new XMLHttpRequest();
    request.upload.onprogress = function (e) {
        console.log("progress " + e.loaded + "/" + e.total);

        // let percent = Math.round(e.loaded / e.total * 100);
        // progressBar.width(percent + '%').html(percent + '%');
        // progressBar[0].style.width = percent + "%";
    }
    request.upload.onload = function (e) {
        console.log("progress completed");

        // progressBar.width(100 + '%').html(100 + '%');
    }
    request.open('post', uploadForm.action, true);
    request.setRequestHeader("Content-Type", "multipart/form-data");
    request.send(new FormData(uploadForm));
}

$(document).ready(renderVideosTable);
