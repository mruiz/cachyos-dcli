#!/usr/bin/env python3
import os
import re
import subprocess
import sys

from PySide6.QtCore import Property, QMetaObject, QObject, Qt, QThread, Signal, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


class FFmpegWorker(QObject):
    progress_updated = Signal(float, str)  # Global percentage, current filename
    finished = Signal()
    error = Signal(str)

    def __init__(self, files):
        super().__init__()
        self.files = files
        self.is_cancelled = False

    def run(self):
        try:
            total_duration = 0
            file_durations = []

            # 1. Calculate total duration for global progress
            for file in self.files:
                duration = self.get_duration(file)
                file_durations.append(duration)
                total_duration += duration

            if total_duration == 0:
                self.error.emit("Could not determine duration for any files.")
                return

            processed_duration = 0
            for idx, file in enumerate(self.files):
                if self.is_cancelled:
                    break

                filename = os.path.basename(file)
                output = f"{os.path.splitext(file)[0]}_dnxhr_hqx.mov"
                duration = file_durations[idx]

                # Start FFmpeg process
                cmd = [
                    "ffmpeg",
                    "-hide_banner",
                    "-y",
                    "-i",
                    file,
                    "-c:v",
                    "dnxhd",
                    "-profile:v",
                    "dnxhr_hqx",
                    "-vf",
                    "format=yuv422p10le",
                    "-c:a",
                    "pcm_s24le",
                    output,
                ]

                process = subprocess.Popen(
                    cmd,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    universal_newlines=True,
                    bufsize=1,
                )

                if process.stdout is None:
                    self.error.emit("FFmpeg failed to initialize output stream.")
                    break

                for line in process.stdout:
                    if self.is_cancelled:
                        process.terminate()
                        break

                    # Parse time=HH:MM:SS.ms
                    match = re.search(r"time=([0-9:]+\.[0-9]+)", line)
                    if match:
                        time_str = match.group(1)
                        secs = self.parse_time(time_str)

                        # Global progress calculation
                        global_progress = (
                            (processed_duration + secs) / total_duration
                        ) * 100
                        self.progress_updated.emit(min(global_progress, 99.9), filename)

                process.wait()
                processed_duration += duration

            self.progress_updated.emit(100.0, "All files converted!")
            self.finished.emit()

        except Exception as e:
            self.error.emit(str(e))

    def get_duration(self, file):
        cmd = [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=nk=1:nw=1",
            file,
        ]
        try:
            result = subprocess.check_output(cmd, universal_newlines=True).strip()
            return float(result)
        except Exception:
            return 0.0

    def parse_time(self, time_str):
        parts = time_str.split(":")
        if len(parts) == 3:  # HH:MM:SS.ms
            return float(parts[0]) * 3600 + float(parts[1]) * 60 + float(parts[2])
        elif len(parts) == 2:  # MM:SS.ms
            return float(parts[0]) * 60 + float(parts[1])
        else:  # SS.ms
            return float(parts[0])


class Bridge(QObject):
    progress_changed = Signal()

    def __init__(self, worker):
        super().__init__()
        self._progress = 0.0
        self._current_file = "Initializing..."
        self.worker = worker

        worker.progress_updated.connect(self.update_progress)
        worker.finished.connect(self.on_finished)
        worker.error.connect(self.on_error)

    @Property(float, notify=progress_changed)
    def progress(self):
        return self._progress

    @Property(str, notify=progress_changed)
    def current_file(self):
        return self._current_file

    @Slot(float, str)
    def update_progress(self, val, filename):
        self._progress = val
        self._current_file = filename
        self.progress_changed.emit()

    @Slot()
    def cancel_conversion(self):
        self.worker.is_cancelled = True
        self._current_file = "Cancelling..."
        self.progress_changed.emit()

    @Slot()
    def on_finished(self):
        self._progress = 100.0
        self._current_file = "Conversion Complete!"
        self.progress_changed.emit()
        # Quit the application after a short delay to let the user see the message
        app = QGuiApplication.instance()
        if app:
            QMetaObject.invokeMethod(app, "quit", Qt.ConnectionType.QueuedConnection)

    @Slot(str)
    def on_error(self, err):
        self._current_file = f"Error: {err}"
        self.progress_changed.emit()


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    # Arguments passed to script
    files = sys.argv[1:]
    if not files:
        print("No files provided.")
        sys.exit(1)

    engine = QQmlApplicationEngine()

    # Setup worker and bridge
    worker = FFmpegWorker(files)
    bridge = Bridge(worker)

    # Inject bridge into QML
    engine.rootContext().setContextProperty("bridge", bridge)

    # Load QML
    qml_file = os.path.join(os.path.dirname(__file__), "to_dnxhr.qml")
    engine.load(qml_file)

    # Start the worker in a separate thread
    thread = QThread()
    worker.moveToThread(thread)
    thread.started.connect(worker.run)
    thread.start()

    sys.exit(app.exec())
