<?php

$targetPath = "uploads/" . basename($_FILES["video"]["name"]);
move_uploaded_file($_FILES["video"]["tmp_name"], $targetPath);