// Stats HUD launcher ("Stats HUD.exe"): starts the modded game in Adobe's Flash Player projector.
//
// Written next to isaac_stats.swf and flashplayer_32_sa.exe by the patcher. It ignores its own command-line
// arguments, so it can be used as a Steam launch option ("...\Stats HUD.exe" %command%): Steam appends the
// original game's path, which the projector would otherwise try to open as the movie. It waits for the
// projector to close, so Steam shows the game as running and counts the playtime.
//
// Build (done by flash/tools/make_payload.py with the .NET Framework compiler that ships with Windows):
//   csc /target:winexe /optimize /out:"Stats HUD.exe" StatsHUDLauncher.cs
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

[assembly: AssemblyTitle("Stats HUD")]
[assembly: AssemblyDescription("Starts The Binding of Isaac (Flash) with the Stats HUD")]
[assembly: AssemblyProduct("Stats HUD for The Binding of Isaac (Flash)")]

static class StatsHUDLauncher
{
    [STAThread]
    static int Main()
    {
        string dir = AppDomain.CurrentDomain.BaseDirectory;
        string projector = Path.Combine(dir, "flashplayer_32_sa.exe");
        string swf = Path.Combine(dir, "isaac_stats.swf");
        if (!File.Exists(projector) || !File.Exists(swf))
        {
            MessageBox.Show("flashplayer_32_sa.exe and isaac_stats.swf must be in the same folder as Stats HUD.exe:\n" + dir +
                            "\n\nRun Stats_HUD_Patcher.exe again to recreate them.", "Stats HUD",
                            MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
        ProcessStartInfo start = new ProcessStartInfo(projector, "\"" + swf + "\"");
        start.WorkingDirectory = dir;
        start.UseShellExecute = false;
        using (Process game = Process.Start(start))
        {
            game.WaitForExit();
            return game.ExitCode;
        }
    }
}
