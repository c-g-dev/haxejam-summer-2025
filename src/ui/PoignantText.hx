package ui;

import h2d.Object;
import h2d.Text;
import h2d.Font;
import h2d.filter.DropShadow;
import heaps.coroutine.Future;
import heaps.coroutine.Coro;
import heaps.coroutine.Coroutine;
import heaps.coroutine.Coroutine.CoroutineContext;

class PoignantText extends Object {
    var lines: Array<String>;
    var font: Font;
    var textScale: Float;

    var letterFadeDuration: Float = 0.06;
    var linePauseDuration: Float = 0.6;
    var lineSpacingMultiplier: Float = 1.45;

    var letterNodes: Array<Text> = [];
    var lineStartIndex: Array<Int> = [];
    var lineLetterCounts: Array<Int> = [];
    var lineWidths: Array<Float> = [];

    var didBuild: Bool = false;
    var skipToComplete: Bool = false;
    var currentFuture: Future;

    public function new(lines: Array<String>, ?font: Font, ?textScale: Float) {
        super();
        this.lines = lines;
        this.font = font != null ? font : hxd.Res.fonts.plex_mono_64.toFont();
        this.textScale = textScale != null ? textScale : 0.30;
                this.filter = new DropShadow(0, 0, 0x000000, 1.0, 6, 2);
    }

    function buildLetters(): Void {
        if (didBuild) return;

        var y: Float = 0;
        var lineHeight: Float = font.lineHeight * textScale * lineSpacingMultiplier;

        for (i in 0...lines.length) {
            var line = lines[i];
            var startIndex = letterNodes.length;
            var cursorX: Float = 0;

            if (line != null && line.length > 0) {
                for (cIx in 0...line.length) {
                    var ch = line.charAt(cIx);
                    var t = new Text(font, this);
                    t.text = ch;
                    t.scaleX = textScale;
                    t.scaleY = textScale;
                    t.alpha = 0;
                    t.textColor = 0xFFFFFF;
                    t.dropShadow = { dx: 3, dy: 3, color: 0x000000, alpha: 1.0 };
                    t.x = cursorX;
                    t.y = y;
                                        var advance = t.textWidth * t.scaleX;
                    cursorX += advance;
                    letterNodes.push(t);
                }
            }

            var count = (line == null) ? 0 : line.length;
            lineStartIndex.push(startIndex);
            lineLetterCounts.push(count);
            lineWidths.push(cursorX);
            y += lineHeight;
        }

                var maxLineWidth: Float = 0;
        for (w in lineWidths) if (w > maxLineWidth) maxLineWidth = w;
        for (li in 0...lines.length) {
            var count = lineLetterCounts[li];
            if (count == 0) continue;
            var start = lineStartIndex[li];
            var width = lineWidths[li];
            var offset = (maxLineWidth - width) * 0.5;
            if (offset != 0) {
                for (k in 0...count) {
                    var n = letterNodes[start + k];
                    n.x += offset;
                }
            }
        }

        didBuild = true;
    }

    public function start(): Future {
        if (currentFuture != null && !currentFuture.isComplete) return currentFuture;

        var lineIndex: Int = 0;
        var charIndex: Int = 0;
        var inLinePause: Bool = false;
        var phaseStartTime: Float = 0.0;

        var c = Coro.start((ctx: CoroutineContext) -> {
            Coro.once(() -> {
                buildLetters();
                phaseStartTime = ctx.elapsed;
            });

            if (skipToComplete) {
                                for (n in letterNodes) n.alpha = 1.0;
                return Stop;
            }

            if (lineIndex >= lines.length) {
                return Stop;
            }

            var lettersInLine = lineLetterCounts[lineIndex];

            if (lettersInLine == 0) {
                                if (!inLinePause) {
                    inLinePause = true;
                    phaseStartTime = ctx.elapsed;
                }
                var pauseRatio = (ctx.elapsed - phaseStartTime) / linePauseDuration;
                if (pauseRatio >= 1.0) {
                    lineIndex++;
                    charIndex = 0;
                    inLinePause = false;
                    phaseStartTime = ctx.elapsed;
                }
                return WaitNextFrame;
            }

            if (!inLinePause) {
                if (charIndex < lettersInLine) {
                    var letterFlatIndex = lineStartIndex[lineIndex] + charIndex;
                    var letter = letterNodes[letterFlatIndex];
                    var ratio = (ctx.elapsed - phaseStartTime) / letterFadeDuration;
                    if (ratio >= 1.0) {
                        letter.alpha = 1.0;
                        charIndex++;
                        phaseStartTime = ctx.elapsed;
                    } else {
                        letter.alpha = ratio;
                    }
                    return WaitNextFrame;
                } else {
                                        if (lineIndex >= lines.length - 1) {
                        return Stop;
                    }
                    inLinePause = true;
                    phaseStartTime = ctx.elapsed;
                    return WaitNextFrame;
                }
            } else {
                                var ratio = (ctx.elapsed - phaseStartTime) / linePauseDuration;
                if (ratio >= 1.0) {
                    lineIndex++;
                    charIndex = 0;
                    inLinePause = false;
                    phaseStartTime = ctx.elapsed;
                }
                return WaitNextFrame;
            }
        });

        currentFuture = c.future();
        return currentFuture;
    }

    public function immediateComplete(): Void {
        skipToComplete = true;
        if (!didBuild) buildLetters();
        for (n in letterNodes) n.alpha = 1.0;
    }
}
