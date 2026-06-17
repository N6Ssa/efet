$code = @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.Text;

public static class LogoTracer
{
    public static string Trace(string file, int alphaThresh, double epsilon)
    {
        Bitmap b = new Bitmap(file);
        int w = b.Width, h = b.Height;
        bool[,] f = new bool[w, h];
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++)
                f[x, y] = b.GetPixel(x, y).A > alphaThresh;
        b.Dispose();

        // boundary edges, filled pixel traversed clockwise (y down)
        // key: start corner id, val: list of end corner ids
        int W = w + 1;
        var edges = new Dictionary<long, List<long>>();
        Action<long, long> add = delegate(long a, long bb)
        {
            List<long> l;
            if (!edges.TryGetValue(a, out l)) { l = new List<long>(); edges[a] = l; }
            l.Add(bb);
        };
        Func<int, int, long> P = delegate(int x, int y) { return (long)y * W + x; };
        Func<int, int, bool> F = delegate(int x, int y)
        {
            if (x < 0 || y < 0 || x >= w || y >= h) return false;
            return f[x, y];
        };
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                if (!f[x, y]) continue;
                if (!F(x, y - 1)) add(P(x, y), P(x + 1, y));         // top, +x
                if (!F(x + 1, y)) add(P(x + 1, y), P(x + 1, y + 1)); // right, +y
                if (!F(x, y + 1)) add(P(x + 1, y + 1), P(x, y + 1)); // bottom, -x
                if (!F(x - 1, y)) add(P(x, y + 1), P(x, y));         // left, -y
            }
        }

        var sb = new StringBuilder();
        var ci = CultureInfo.InvariantCulture;
        while (edges.Count > 0)
        {
            long start = -1;
            foreach (var k in edges.Keys) { start = k; break; }
            var loop = new List<long>();
            long cur = start;
            long prev = -1;
            while (true)
            {
                loop.Add(cur);
                List<long> outs;
                if (!edges.TryGetValue(cur, out outs) || outs.Count == 0) break;
                long next;
                if (outs.Count == 1) next = outs[0];
                else
                {
                    // ambiguous corner: pick the sharpest clockwise turn
                    next = outs[0];
                    if (prev >= 0)
                    {
                        int cx = (int)(cur % W), cy = (int)(cur / W);
                        int px = (int)(prev % W), py = (int)(prev / W);
                        int dx = cx - px, dy = cy - py;
                        double best = -10;
                        foreach (long cand in outs)
                        {
                            int nx = (int)(cand % W), ny = (int)(cand / W);
                            int ex = nx - cx, ey = ny - cy;
                            double cross = dx * ey - dy * ex; // >0 = right turn (y down)
                            double dot = dx * ex + dy * ey;
                            double score = cross * 2 + dot;
                            if (score > best) { best = score; next = cand; }
                        }
                    }
                }
                outs.Remove(next);
                if (outs.Count == 0) edges.Remove(cur);
                prev = cur;
                cur = next;
                if (cur == start) break;
            }
            if (loop.Count < 3) continue;

            // to points
            var pts = new List<double[]>();
            foreach (long id in loop) pts.Add(new double[] { id % W, id / W });
            // collapse collinear
            var col = new List<double[]>();
            int n = pts.Count;
            for (int i = 0; i < n; i++)
            {
                double[] a = pts[(i + n - 1) % n], m = pts[i], c = pts[(i + 1) % n];
                double cr = (m[0] - a[0]) * (c[1] - m[1]) - (m[1] - a[1]) * (c[0] - m[0]);
                if (Math.Abs(cr) > 1e-9) col.Add(m);
            }
            if (col.Count < 3) continue;
            var simp = Simplify(col, epsilon);
            if (simp.Count < 3) continue;

            sb.Append("M");
            for (int i = 0; i < simp.Count; i++)
            {
                if (i > 0) sb.Append("L");
                sb.Append(simp[i][0].ToString("0.#", ci));
                sb.Append(" ");
                sb.Append(simp[i][1].ToString("0.#", ci));
            }
            sb.Append("Z");
        }
        return sb.ToString();
    }

    static List<double[]> Simplify(List<double[]> pts, double eps)
    {
        // closed-loop Douglas-Peucker: split at two extreme points
        int n = pts.Count;
        if (n < 5) return pts;
        int i0 = 0, i1 = n / 2;
        var part1 = DP(pts.GetRange(i0, i1 - i0 + 1), eps);
        var rest = new List<double[]>();
        rest.AddRange(pts.GetRange(i1, n - i1));
        rest.Add(pts[0]);
        var part2 = DP(rest, eps);
        var outp = new List<double[]>();
        outp.AddRange(part1.GetRange(0, part1.Count - 1));
        outp.AddRange(part2.GetRange(0, part2.Count - 1));
        return outp;
    }

    static List<double[]> DP(List<double[]> pts, double eps)
    {
        if (pts.Count < 3) return new List<double[]>(pts);
        int idx = -1; double dmax = 0;
        double[] a = pts[0], b = pts[pts.Count - 1];
        for (int i = 1; i < pts.Count - 1; i++)
        {
            double d = PerpDist(pts[i], a, b);
            if (d > dmax) { dmax = d; idx = i; }
        }
        if (dmax > eps)
        {
            var left = DP(pts.GetRange(0, idx + 1), eps);
            var right = DP(pts.GetRange(idx, pts.Count - idx), eps);
            var res = new List<double[]>();
            res.AddRange(left.GetRange(0, left.Count - 1));
            res.AddRange(right);
            return res;
        }
        return new List<double[]> { a, b };
    }

    static double PerpDist(double[] p, double[] a, double[] b)
    {
        double dx = b[0] - a[0], dy = b[1] - a[1];
        double len = Math.Sqrt(dx * dx + dy * dy);
        if (len < 1e-12) return Math.Sqrt((p[0] - a[0]) * (p[0] - a[0]) + (p[1] - a[1]) * (p[1] - a[1]));
        return Math.Abs(dx * (a[1] - p[1]) - dy * (a[0] - p[0])) / len;
    }
}
"@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

$d = [LogoTracer]::Trace('C:\Users\Pasha\efet-studio\assets\hero\logo-efet-crea.png', 127, 0.7)
$svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1356 400"><path d="' + $d + '" fill="#2b2a29" fill-rule="evenodd"/></svg>'
Set-Content -Path 'C:\Users\Pasha\efet-studio\assets\hero\logo-efet-crea.svg' -Value $svg -Encoding UTF8
Write-Output "SVG saved, path length: $($d.Length) chars"
