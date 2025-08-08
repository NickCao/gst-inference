import argparse
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import babeltrace


def parse_and_visualize_trace_bt1(trace_path: str):
    """
    Parses a Gst-Shark trace and then creates visualizations.
    """
    print(f"[*] Parsing trace from: {trace_path} (using Babeltrace 1 API)")

    framerate = []
    proctime = []

    collection = babeltrace.TraceCollection()
    collection.add_trace(trace_path, "ctf")

    inittime = None
    for event in collection.events:
        thistime = np.datetime64(event.timestamp, "ns")
        if inittime is not None:
            offset = thistime - inittime
        else:
            if event.name != "init":
                continue
        match event.name:
            case "init":
                inittime = thistime
            case "framerate":
                framerate.append(
                    {
                        "offset": offset,
                        "pad": event["pad"],
                        "fps": event["fps"],
                    }
                )
            case "proctime":
                proctime.append(
                    {
                        "offset": offset,
                        "element": event["element"],
                        "time": event["time"],
                    }
                )
            case "cpuusage":
                pass
            case _:
                raise NotImplementedError

    # framerate = pd.DataFrame(framerate)
    # framerate = framerate.pivot(index="offset", columns="pad", values="fps")
    # framerate = framerate.interpolate(method="spline", limit_direction="both", order=3)
    # ax = framerate.plot.line()

    proctime = pd.DataFrame(proctime)
    proctime = proctime.pivot(index="offset", columns="element", values="time")
    proctime = proctime.interpolate(method="spline", limit_direction="both", order=3)
    proctime = proctime.clip(lower=0)
    bx = proctime.plot.area()
    bx.set_ylim(0, proctime.sum(axis=1).quantile(0.99))

    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Parse and Visualize a Gst-Shark trace with the legacy Babeltrace 1 library."
    )
    parser.add_argument("trace_path", type=str, help="Path to the CTF trace directory.")
    args = parser.parse_args()
    parse_and_visualize_trace_bt1(args.trace_path)
