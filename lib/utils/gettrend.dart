String getOverallTrend(List<double> values) {
  int up = 0;
  int down = 0;

  for (var v in values) {
    if (v > 0) {
      up++;
    } else if (v < 0) {
      down++;
    }
  }

  if (up > down) return "up";
  if (down > up) return "down";
  return "flat";
}
