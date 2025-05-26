round_salary() {
    level endon("end_game");
    for (;;) {
        level waittill("end_of_round");
        players = getPlayers();
        foreach (player in players) {
            newScore = 100 + int(75 * level.round_number);
            player.score += newScore;
        }
    }
}