#!/bin/bash

screen_width=$(xdpyinfo | awk '/dimensions/{print $2}' | awk -Fx '{print $1}')
screen_height=$(xdpyinfo | awk '/dimensions/{print $2}' | awk -Fx '{print $2}')

width=$((screen_width / 2))
height=$((screen_height / 2))

gst-launch-1.0 -e \
  videomixer name=mixer \
      sink_0::xpos=0 sink_0::ypos=0 sink_0::width=$width sink_0::height=$height \
      sink_1::xpos=$width sink_1::ypos=0 sink_1::width=$width sink_1::height=$height \
      sink_2::xpos=0 sink_2::ypos=$height sink_2::width=$width sink_2::height=$height \
      sink_3::xpos=$width sink_3::ypos=$height sink_3::width=$width sink_3::height=$height \
      ! videoconvert ! autovideosink sync=false \
  filesrc location=/home/ubuntu/yolov7/video/crowd.mp4 ! qtdemux ! h264parse ! nvv4l2decoder ! queue ! \
      nvvidconv ! video/x-raw, format = I420, width = $width, height = $height ! videoconvert ! queue ! mixer.sink_0 \
  filesrc location=/home/ubuntu/yolov7/video/pose.mp4 ! qtdemux ! h264parse ! nvv4l2decoder ! queue ! \
      nvvidconv ! video/x-raw, format = I420, width = $width, height = $height ! videoconvert ! queue ! mixer.sink_1 \
  filesrc location=/home/ubuntu/yolov7/video/face.mp4 ! qtdemux ! h264parse ! nvv4l2decoder ! queue ! \
      nvvidconv ! video/x-raw, format = I420, width = $width , height = $height ! videoconvert ! queue ! mixer.sink_2 \
  filesrc location=/home/ubuntu/yolov7/video/road.mp4 ! qtdemux ! h264parse ! nvv4l2decoder ! queue ! \
      nvvidconv ! video/x-raw, format = I420, width = $width, height = $height ! videoconvert ! queue ! mixer.sink_3 &

gst_pid=$!
echo
while : ; do
  read -rsn1 input
  if [ "$input" = "q" ]; then
    kill $gst_pid
    break
  fi
done