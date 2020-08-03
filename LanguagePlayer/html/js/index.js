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
    api.remove(id, function() {
        $("#video-" + id).remove();
    });
}

function fileSelected(element) {
//    var input = $(element);
//    var html = input.parent().html().trim();
//    var inputString = " <input" + html.split("<input")[1];
//    input.parent().html(input.val() + inputString);
}

$(function(){
    var ul = $('#upload ul');

    $('#upload').fileupload({
        add: function (e, data) {

            var tpl = $('<li class="working"><input type="text" value="0" data-width="48" data-height="48"'+
                ' data-fgColor="#0788a5" data-readOnly="1" data-bgColor="#3e4043" /><p></p><span></span></li>');

            tpl.find('p').text(data.files[0].name)
                         .append('<i>' + formatFileSize(data.files[0].size) + '</i>');

            data.context = tpl.appendTo(ul);

//            tpl.find('input').knob();

            tpl.find('span').click(function(){

                if(tpl.hasClass('working')){
                    jqXHR.abort();
                }

                tpl.fadeOut(function(){
                    tpl.remove();
                });

            });

            var jqXHR = data.submit();
        },
        progress: function(e, data){

            var progress = parseInt(data.loaded / data.total * 100, 10);
            data.context.find('input').val(progress).change();

            if(progress == 100){
                data.context.removeClass('working');
            }
        },
        fail:function(e, data){
            data.context.addClass('error');
        }

    });

    function formatFileSize(bytes) {
        if (typeof bytes !== 'number') {
            return '';
        }

        if (bytes >= 1000000000) {
            return (bytes / 1000000000).toFixed(2) + ' GB';
        }

        if (bytes >= 1000000) {
            return (bytes / 1000000).toFixed(2) + ' MB';
        }

        return (bytes / 1000).toFixed(2) + ' KB';
    }

});

$(document).ready(renderVideosTable);
