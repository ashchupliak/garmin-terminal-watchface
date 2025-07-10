import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;

class DigitalWatchFaceApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() {
        return [new DigitalWatchFaceView()];
    }
}

class DigitalWatchFaceView extends WatchUi.WatchFace {
    private var _scanlineOffset as Number = 0;
    private var _noiseOffset as Number = 0;
    private var _characterOffset as Number = 0;

    function initialize() {
        WatchFace.initialize();
    }

    // Draw random white noise background effect
    private function drawWhiteNoise(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var margin = (width * 0.15).toNumber();  // Ensure integer
        
        dc.setColor(0x554400, Graphics.COLOR_TRANSPARENT);  // More visible amber noise
        
        // Draw larger random noise pixels around the terminal
        for (var i = 0; i < 80; i++) {  // More noise pixels
            var x = ((_noiseOffset + i * 7) % width);
            var y = ((_noiseOffset + i * 11) % height);
            
            // Only draw outside the terminal area
            if (x < margin || x > width - margin || y < margin || y > height - margin) {
                if ((x + y + _noiseOffset) % 3 == 0) {  // Random pattern
                    dc.fillRectangle(x, y, 2, 2);  // Bigger noise pixels
                }
            }
        }
        
        _noiseOffset = (_noiseOffset + 1) % 100;
    }

    // Draw floating terminal characters
    private function drawFloatingCharacters(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var margin = (width * 0.15).toNumber();  // Ensure integer
        
        var chars = ["0", "1", ".", "-", "*", "+", ":", "/", "\\", "|", "#", "@", "$", "%"];
        
        dc.setColor(0x665500, Graphics.COLOR_TRANSPARENT);  // More prominent amber
        
        // Draw bigger floating characters around the terminal
        for (var i = 0; i < 25; i++) {  // More characters
            var x = ((i * 19 + _characterOffset) % width);
            var y = ((i * 31 + _characterOffset * 2) % height);
            
            // Only draw outside the terminal area
            if (x < margin - 5 || x > width - margin + 5 || y < margin - 5 || y > height - margin + 5) {
                var charIndex = (i + _characterOffset / 8) % chars.size();
                dc.drawText(
                    x,
                    y,
                    Graphics.FONT_SMALL,  // Bigger font for characters
                    chars[charIndex],
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
        }
        
        _characterOffset = (_characterOffset + 1) % 300;  // Slower movement
    }

    // Draw CRT phosphor glow effect
    private function drawCRTGlow(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var margin = (width * 0.15).toNumber();  // Ensure integer
        
        // Draw more prominent glow around the invisible terminal area
        dc.setColor(0x443300, Graphics.COLOR_TRANSPARENT);  // More visible amber glow
        
        // Bigger outer glow rectangles
        for (var i = 1; i <= 6; i++) {  // More glow layers
            dc.drawRectangle(margin - i, margin - i, 
                           width - (2 * margin) + (2 * i), 
                           height - (2 * margin) + (2 * i));
        }
        
        // Add some scattered glow dots
        for (var j = 0; j < 20; j++) {
            var terminalWidth = (width - 2 * margin).toNumber();
            var terminalHeight = (height - 2 * margin).toNumber();
            var glowX = margin + ((j * 13) % terminalWidth);
            var glowY = margin + ((j * 17) % terminalHeight);
            dc.fillCircle(glowX, glowY, 1);
        }
    }

    // Draw time in terminal format with bigger fonts
    private function drawTerminalTime(dc, clockTime) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var margin = (width * 0.15).toNumber();  // Ensure integer
        
        // Calculate spacing with extra room for larger time font
        var availableHeight = height - (2 * margin) - 30;
        var elementSpacing = availableHeight / 9; // More spacing for larger fonts
        var startY = margin + 15;
        
        dc.setColor(0xFF8C00, Graphics.COLOR_TRANSPARENT);  // Dark orange
        
        // Command prompt
        dc.drawText(
            margin + 12,
            startY,
            Graphics.FONT_XTINY,
            "$ date",
            Graphics.TEXT_JUSTIFY_LEFT
        );
        
        // Format date and time separately
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        
        var dateStr = Lang.format("$1$ $2$ $3$", [
            days[today.day_of_week - 1],
            months[today.month - 1],
            today.day.format("%02d")
        ]);
        
        var timeStr = Lang.format("$1$:$2$:$3$", [
            clockTime.hour.format("%02d"),
            clockTime.min.format("%02d"),
            clockTime.sec.format("%02d")
        ]);
        
        // Draw the date output
        dc.setColor(0xFFB347, Graphics.COLOR_TRANSPARENT);  // Light amber for output
        dc.drawText(
            margin + 12,
            startY + elementSpacing,
            Graphics.FONT_XTINY,  // Smaller font for date to save space
            dateStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );
        
        // Draw the time output with extra spacing for larger font
        dc.drawText(
            margin + 12,
            startY + (2.5 * elementSpacing).toNumber(),  // Extra space for larger font
            Graphics.FONT_SMALL,  // Bigger font for time
            timeStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    // Draw stress level in terminal format
    private function drawStressLevel(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var margin = (width * 0.15).toNumber();  // Ensure integer
        
        // Calculate spacing with extra room
        var availableHeight = height - (2 * margin) - 30;
        var elementSpacing = availableHeight / 9;
        var startY = margin + 15;
        
        dc.setColor(0xFF8C00, Graphics.COLOR_TRANSPARENT);
        
        // Command prompt - moved further down to avoid time overlap
        dc.drawText(
            margin + 12,
            startY + (4 * elementSpacing).toNumber(),
            Graphics.FONT_XTINY,
            "$ stress",
            Graphics.TEXT_JUSTIFY_LEFT
        );
        
        // Get stress data
        var info = ActivityMonitor.getInfo();
        var stressStr = "-- level";
        
        if (info has :stressScore && info.stressScore != null) {
            stressStr = Lang.format("$1$/100", [info.stressScore.toString()]);
        }
        
        dc.setColor(0xFFB347, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            margin + 12,
            startY + (5 * elementSpacing).toNumber(),
            Graphics.FONT_XTINY,
            stressStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    // Draw battery status
    private function drawBatteryStatus(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var margin = (width * 0.15).toNumber();  // Ensure integer
        
        // Calculate spacing with extra room
        var availableHeight = height - (2 * margin) - 30;
        var elementSpacing = availableHeight / 9;
        var startY = margin + 15;
        
        dc.setColor(0xFF8C00, Graphics.COLOR_TRANSPARENT);
        
        // Command prompt
        dc.drawText(
            margin + 12,
            startY + (6 * elementSpacing).toNumber(),
            Graphics.FONT_XTINY,
            "$ power",
            Graphics.TEXT_JUSTIFY_LEFT
        );
        
        // Get battery level
        var battery = System.getSystemStats().battery;
        var batteryStr = Lang.format("Battery: $1$%", [battery.format("%.0f")]);
        
        // Color based on battery level - amber variations
        if (battery > 20) {
            dc.setColor(0xFFB347, Graphics.COLOR_TRANSPARENT);  // Light amber for good
        } else {
            dc.setColor(0xFF4500, Graphics.COLOR_TRANSPARENT);  // Orange red for low
        }
        
        dc.drawText(
            margin + 12,
            startY + (7 * elementSpacing).toNumber(),
            Graphics.FONT_XTINY,
            batteryStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    // Draw blinking cursor
    private function drawBlinkingCursor(dc, clockTime) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var margin = (width * 0.15).toNumber();  // Ensure integer
        
        // Calculate spacing with extra room
        var availableHeight = height - (2 * margin) - 30;
        var elementSpacing = availableHeight / 9;
        var startY = margin + 15;
        
        // Blink every second
        if (clockTime.sec % 2 == 0) {
            dc.setColor(0xFF8C00, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                margin + 12,
                startY + (8 * elementSpacing).toNumber(),
                Graphics.FONT_XTINY,
                "$ █",
                Graphics.TEXT_JUSTIFY_LEFT
            );
        } else {
            dc.setColor(0xFF8C00, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                margin + 12,
                startY + (8 * elementSpacing).toNumber(),
                Graphics.FONT_XTINY,
                "$ _",
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }

    // Draw scan lines effect for CRT look
    private function drawScanLines(dc) {
        var height = dc.getHeight();
        
        dc.setColor(0x331A00, Graphics.COLOR_TRANSPARENT);  // Very dark amber
        
        // Draw horizontal scan lines across entire screen
        for (var y = _scanlineOffset; y < height; y += 3) {  // Closer scan lines
            dc.drawLine(0, y, dc.getWidth(), y);
        }
        
        // Update scan line offset for subtle movement
        _scanlineOffset = (_scanlineOffset + 1) % 3;
    }

    function onLayout(dc as Dc) as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        
        // Clear screen with dark amber terminal background
        dc.setColor(0x1A0D00, 0x1A0D00);  // Very dark amber/brown background
        dc.clear();
        
        // Draw animated background effects
        drawWhiteNoise(dc);
        drawFloatingCharacters(dc);
        drawCRTGlow(dc);
        drawScanLines(dc);
        
        // Draw terminal content (no visible borders)
        drawTerminalTime(dc, clockTime);
        drawStressLevel(dc);
        drawBatteryStatus(dc);
        drawBlinkingCursor(dc, clockTime);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }
} 