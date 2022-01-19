#!/usr/bin/env roseus

(defvar *base-frame-id* "/base_link")

(load "package://jsk_pcl_ros/euslisp/bounding-box-to-cube.l")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "geometry_msgs")

(setq *tfl* (instance ros::transform-listener :init))

(defun bounding-box->camera-frame-cube (msg)
  (ros::ros-error "hoge")
  (send *tfl* :wait-for-transform *base-frame-id* (send msg :header :frame_id) (ros::time 0) 10)
  (let ((cube (bounding-box->cube msg))
        (cam-coords (send *tfl* :lookup-transform
                            *base-frame-id* (send msg :header :frame_id)
                            (ros::time 0))))
    (format t "raw cube: ~A ~%" cube)
    (format t "cam-coords: ~A ~%" cam-coords)
    (send cube :newcoords (send cam-coords :transform cube))
    cube))

(defun vector->list(vector)
  (reverse vector)
  (setq length (length vector))
  (setq list ())
  (setq cnt 0)
  (while
      (< cnt length)
    (setq x (elt vector cnt))
    (push x list)
    (incf cnt))
  list
  (print list))
