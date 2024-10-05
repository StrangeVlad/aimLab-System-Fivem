// Menu & Other

window.addEventListener("message", (event) => {
    if (event.data.type === "show") {
        $(".profileName").html(event.data.playername);
        $(".profileImg").css({"background-image": "url("+event.data.photo+")"})
        $(".General").fadeIn(300);
        $.post(`https://${GetParentResourceName()}/viber-aimlab:client:FetchLeaderboard`, JSON.stringify({}))
    } else if (event.data.type === "updateLeader") {
        let data = event.data.data

        $(".leaderPlayerList").html("");

        var playerArray = Object.entries(data).map(([key, value]) => ({ key, ...value }));
        playerArray.sort((a, b) => b.score - a.score);

        for (var i = 0; i < playerArray.length; i++) {
            var player = playerArray[i];
            var rank = i + 1;
            
            $(".leaderPlayerList").append(`
            <div class="leaderPlayerBox">
                <div class="leaderPlayerIcon">#${rank}</div>
                <div class="leaderPlayerProfileBox">
                <div
                    class="leaderPlayerProfileImg"
                    style="
                    background-image: url(${player.photo});
                    "
                ></div>
                <h2 class="leaderPlayerProfileName">${player.plyname}</h2>
                </div>
                <h2 class="leaderPlayerScoreText" style="width: 12.0833vw">
                ${player.total_training}
                </h2>
                <h2 class="leaderPlayerScoreText" style="width: 7.7083vw">
                ${"%" + calculatePercentage(player.shooted_target, player.total_target)}
                </h2>
                <h2
                class="leaderPlayerScoreText"
                style="width: 10.625vw; text-align: right"
                >
                ${player.score}
                </h2>
            </div>
            `)

            if ($(".profileName").html() === player.plyname) {
                $("#scoreId").html(player.score)
                $("#rankId").html("#" + rank)
            }
            
        }
        
    } else if (event.data.type === "hide") {
        $(".popupSide").fadeOut(300);
        $(".General").fadeOut(300);
        Mode_Clicked = false
    } else if (event.data.type == "countdown") {
        $(".countdown").fadeIn(350);
    } else if (event.data.type == "countdown-update") {
        if (event.data.text == "START!") {
          $(".countdown").fadeOut(350);
          setTimeout(() => {$(".countdown").html('<p class="countdown-text">'+event.data.text+'</p>'); $(".countdown").fadeIn(350);}, 500);
        } else {
          $(".countdown").fadeOut(350);
          setTimeout(() => {$(".countdown").html('<p class="countdown-text">'+event.data.text+'</p>'); $(".countdown").fadeIn(350);}, 500);
        }
    } else if (event.data.type == "countdown-close") {
        $(".countdown").fadeOut(350);
        setTimeout(() => {$(".countdown").html('<p class="countdown-text">3</p>');}, 1000);
    } else if (event.data.type == "score-show") {
        $(".scoreTitle").html('<div class="scoreTitle">'+event.data.score_type+'</div>')
        $(".scoreSide").fadeIn(350);
        //scoreTimeBox
    } else if (event.data.type == "score-hide") {
        $(".scoreSide").fadeOut(350);
    } else if (event.data.type == "score-update") {
        if (event.data.score_update_type == "score") {
            $(".scoreNum").html('<div class="scoreNum">'+event.data.score_shooted_target+'<p>/'+event.data.score_total_target+'</p></div>')
        } else if (event.data.score_update_type == "track") {
            $(".scoreNum").html('<div class="scoreNum">'+event.data.score_shooted_target.toFixed(2)+'<p></p></div>')
        } else if (event.data.score_update_type == "dynamic") {
            $(".scoreNum").html('<div class="scoreNum">'+event.data.score_shooted_target+'<p></p></div>')
        }
    } else if (event.data.type == "time-show") {
        $(".scoreTimeBox").fadeIn(350);
    } else if (event.data.type == "time-hide") {
        $(".scoreTimeBox").fadeOut(350);
    } else if (event.data.type == "time-update") {
        $(".scoreTimeText").html('<div class="scoreTimeText">'+event.data.time+'</div>')
    } else if (event.data.type == "finish-show") {
        if (event.data.mode == "Realistic Track" || event.data.mode == "Target Track") {
            $(".trainingScoreBottom").html('<div class="trainingScoreBottom">'+event.data.finish_shooted_target.toFixed(2)+'<p></p></div>')
            $(".trainTitle").html(event.data.mode);
            $(".trainMode").html(event.data.difficulty);
            if (event.data.difficulty == "Easy") {
                $(".trainMode").css({"background": "rgba(71, 255, 74, 0.17)"})
                $(".trainMode").css({"color": "rgba(80, 255, 71, 0.58)"})
            } else if (event.data.difficulty == "Medium") {
                $(".trainMode").css({"background": "rgba(255, 157, 71, 0.17)"})
                $(".trainMode").css({"color": "rgba(255, 157, 71, 0.58)"})
            } else if (event.data.difficulty == "Hard") {
                $(".trainMode").css({"background": "rgba(255, 71, 71, 0.17)"})
                $(".trainMode").css({"color": "rgba(255, 71, 71, 0.58)"})
            }
            $(".trainingScoreBottom2").html("%?");
            $(".trainingScoreBottom3").html(event.data.score.toFixed(2));
            $(".trainProfileText").html(event.data.playername);
            $(".trainProfileImg").css({"background-image": "url("+event.data.photo+")"})
            $(".trainingFinish").fadeIn(350);
        } else if (event.data.mode == "Dynamic Clicking") {
            $(".trainingScoreBottom").html('<div class="trainingScoreBottom">'+event.data.finish_shooted_target+'<p></p></div>')
            $(".trainingScoreTitle").html("Shooted Target");
            $(".trainTitle").html(event.data.mode);
            $(".trainMode").html(event.data.difficulty);
            if (event.data.difficulty == "Easy") {
                $(".trainMode").css({"background": "rgba(71, 255, 74, 0.17)"})
                $(".trainMode").css({"color": "rgba(80, 255, 71, 0.58)"})
            } else if (event.data.difficulty == "Medium") {
                $(".trainMode").css({"background": "rgba(255, 157, 71, 0.17)"})
                $(".trainMode").css({"color": "rgba(255, 157, 71, 0.58)"})
            } else if (event.data.difficulty == "Hard") {
                $(".trainMode").css({"background": "rgba(255, 71, 71, 0.17)"})
                $(".trainMode").css({"color": "rgba(255, 71, 71, 0.58)"})
            }
            $(".trainingScoreBottom2").html("%?");
            $(".trainingScoreBottom3").html(event.data.score.toFixed(2));
            $(".trainProfileText").html(event.data.playername);
            $(".trainProfileImg").css({"background-image": "url("+event.data.photo+")"})
            $(".trainingFinish").fadeIn(350);
        } else {
            $(".trainingScoreBottom").html('<div class="trainingScoreBottom">'+event.data.finish_shooted_target+'<p>/'+event.data.finish_total_target+'</p></div>')
            $(".trainTitle").html(event.data.mode);
            $(".trainMode").html(event.data.difficulty);
            if (event.data.difficulty == "Easy") {
                $(".trainMode").css({"background": "rgba(71, 255, 74, 0.17)"})
                $(".trainMode").css({"color": "rgba(80, 255, 71, 0.58)"})
            } else if (event.data.difficulty == "Medium") {
                $(".trainMode").css({"background": "rgba(255, 157, 71, 0.17)"})
                $(".trainMode").css({"color": "rgba(255, 157, 71, 0.58)"})
            } else if (event.data.difficulty == "Hard") {
                $(".trainMode").css({"background": "rgba(255, 71, 71, 0.17)"})
                $(".trainMode").css({"color": "rgba(255, 71, 71, 0.58)"})
            }
            $(".trainingScoreBottom2").html("%" + calculatePercentage(event.data.finish_shooted_target, event.data.finish_total_target));
            $(".trainingScoreBottom3").html(event.data.score);
            $(".trainProfileText").html(event.data.playername);
            $(".trainProfileImg").css({"background-image": "url("+event.data.photo+")"})
            $(".trainingFinish").fadeIn(350);
        }
    } else if (event.data.type == "finish-hide") {
        $(".trainingFinish").fadeOut(200);
    } else if (event.data.type == "leave-training") {
        $(".weaponBox.selected").removeClass("selected");
        $(".chooseBox.selected").removeClass("selected");
        Mode_Options.Mode = ""
        Mode_Options.Weapon = ""
        Mode_Options.Difficulty = ""
    }
});

function calculatePercentage(value, total) {
    if (total === 0) {
        return 0;
    }
    return Math.round((value / total) * 100);
}

$(document).ready(function () {
    $("#modern-input").on("keyup", function () {
      var value = $(this).val().toLowerCase();
      $(".leaderPlayerBox").filter(function () {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
      });
    });
  });

// Mode

var Mode_Clicked = false
const Mode_Options = {Mode:"", Weapon:"", Difficulty:""}

$(".modeBox").click(function(){
    if (Mode_Clicked == false) {
        Mode_Clicked = true
        $(".popupTitleText").html(this.id);
        if (this.id == "Bot Training") {
            $(".popupModeGif").attr("src","./img/popupImg/bottraining.png");
        } else if (this.id == "Spider Shot") {
            $(".popupModeGif").attr("src","./img/popupImg/spidershot.png");
        } else if (this.id == "Strafe Shooting") {
            $(".popupModeGif").attr("src","./img/popupImg/strafeshooting.png");
        } else if (this.id == "Dynamic Clicking") {
            $(".popupModeGif").attr("src","./img/popupImg/dynamicclicking.png");
        } else if (this.id == "Target Track") {
            $(".popupModeGif").attr("src","./img/popupImg/targettrack.png");
        } else if (this.id == "Realistic Track") {
            $(".popupModeGif").attr("src","./img/popupImg/realistictrack.png");
        }
        $(".popupSide").fadeIn(100);
        Mode_Options.Mode = this.id
    }
})

$(".weaponBox").click(function(){
    var $this = this;
    var current = document.getElementsByClassName("weaponBox selected");
    if (current.length > 0) {
        current[0].className = current[0].className.replace("weaponBox selected", "weaponBox");
    }
    $this.className += " selected";
    Mode_Options.Weapon = $this.id
})

$(".chooseBox").click(function(){
    $(".chooseBox.selected").removeClass("selected");
    var $this = this;
    var current = document.getElementsByClassName("chooseBox selected");
    if (current.length > 0) {
        current[0].className = current[0].className.replace("chooseBox selected", "chooseBox");
    }
    $this.className += " selected";
    Mode_Options.Difficulty = $this.id
})

// Start

$(".startButton").click(function(){
    if (Mode_Options.Weapon != "" && Mode_Options.Difficulty != "") {
        $.post(`https://${GetParentResourceName()}/viber-aimlab:client:TrainingStart`, JSON.stringify({Mode : Mode_Options.Mode, Weapon : Mode_Options.Weapon, Difficulty : Mode_Options.Difficulty, Again : false}))
        $(".weaponBox.selected").removeClass("selected");
        $(".chooseBox.selected").removeClass("selected");
    }
})

// Again

$(".againButton").click(function(){
    $(".trainingFinish").fadeOut(200);
    $(".scoreSide").fadeOut(200);
    $.post(`https://${GetParentResourceName()}/viber-aimlab:client:TrainingStart`, JSON.stringify({Mode : Mode_Options.Mode, Weapon : Mode_Options.Weapon, Difficulty : Mode_Options.Difficulty, Again : true}))
})

// Close

$(document).on("keydown", function () {
    switch (event.keyCode) {
        case 27: // ESC
        $.post("https://viber-aimlab/CloseMenu", JSON.stringify());
        $(".popupSide").fadeOut(300);
        $(".General").fadeOut(300);
        Mode_Clicked = false
        $(".weaponBox.selected").removeClass("selected");
        $(".chooseBox.selected").removeClass("selected");
        Mode_Options.Mode = ""
        Mode_Options.Weapon = ""
        Mode_Options.Difficulty = ""
        break;
    }
});

$(document).on("click", ".exitBox", function () {
    if (Mode_Clicked == false) {
        $.post("https://viber-aimlab/CloseMenu", JSON.stringify());
        $(".General").fadeOut(300);
        $(".weaponBox.selected").removeClass("selected");
        $(".chooseBox.selected").removeClass("selected");
        Mode_Options.Mode = ""
        Mode_Options.Weapon = ""
        Mode_Options.Difficulty = ""
    } else if (Mode_Clicked == true) {
        $(".popupSide").fadeOut(100);
        Mode_Clicked = false
        $(".weaponBox.selected").removeClass("selected");
        $(".chooseBox.selected").removeClass("selected");
        Mode_Options.Mode = ""
        Mode_Options.Weapon = ""
        Mode_Options.Difficulty = ""
    }
});

$(".trainCloseButton").click(function(){
    $(".weaponBox.selected").removeClass("selected");
    $(".chooseBox.selected").removeClass("selected");
    Mode_Options.Mode = ""
    Mode_Options.Weapon = ""
    Mode_Options.Difficulty = ""
    Mode_Clicked = false
    $.post(`https://${GetParentResourceName()}/viber-aimlab:client:FinishMenu:Close`)
})