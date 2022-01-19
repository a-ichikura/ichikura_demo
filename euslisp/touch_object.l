#!/usr/bin/env roseus

(defvar *base-frame-id* "/base_link")

(load "package://spotkinovaeus/spotkinova-interface.l")
(load "package://jsk_pcl_ros/euslisp/bounding-box-to-cube.l")

(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "geometry_msgs")

(ros::roseus "object_touch_node")

(defun touch-callback()
  ;;need :kinova-rest-pose 　
  (send *ri* :body-pose '(0 0.4 0)) ;;To move its head down
  (ros::duration-sleep 1)
  (send *spotkinova* :head-shoulder-p :joint-angle -70)
  (send *spotkinova* :head-elbow-y :joint-angle 0)
  (send *spotkinova* :head :move-end-pos #f(100 0 -150) :world :rotation-axis nil) ;;To do
  (send *ri* :angle-vector (send *spotkinova* :angle-vector) 7000)
  (send *ri* :wait-interpolation)

  (send *ri* :body-pose '(0 0 0)) ;;To move its head up
  (ros::duration-sleep 1)
  (send *spotkinova* :reset-pose)
  (send *ri* :angle-vector (send *spotkinova* :reset-pose) 7000)
  (send *ri* :wait-interpolation)
  (send *ri* :go-pos 0 0 180)
  (send *ri* :wait-interpolation)
  )

(defun touch-object()
  (touch-callback))
