#!/usr/bin/env roseus

(defvar *base-frame-id* "/base_link")

(load "package://spotkinovaeus/spotkinova-interface.l")
(load "utils.l")

(ros::roseus "object_approach_node")
  
(defun move-callback (msg)
  (unless msg
    (print "msg is nil")
    (return-from move-callback nil))
  (unless (send msg :boxes)
    (print "target box is nil")
    (return-from move-callback nil))
  (setq *target-obj* (bounding-box->camera-frame-cube (elt (send msg :boxes) 0)))
  (setq worldpos (scale 0.001 (send *target-obj* :worldpos)))
  (setq x (elt worldpos 0))
  (setq y (elt worldpos 1))
  (setq x (- x 0.85)) ;;stop before reach an object
  (format t "target-obj: ~A~%" *target-obj*)
  (format t "x: ~A y: ~A ~%" x y)
  (send *ri* :angle-vector(send *spotkinova* :kinova-rest-pose) 5000)
  (send *ri* :wait-interpolation)
  (send *ri* :go-pos x y)
  (setq *spin* 1)
  (send *ri* :wait-interpolation)
  )


(defun wait-for-target ()
  (ros::subscribe "/kinova_wrist_camera/depth/color/boxes"
                  jsk_recognition_msgs::BoundingBoxArray #'move-callback))

(defun move-to-object ()
  (send *ri* :angle-vector (send *spotkinova* :reset-pose) 5000)
  (send *ri* :wait-interpolation)
  (send *spotkinova* :head-elbow-y :joint-angle 0)
  (send *spotkinova* :head :move-end-pos #f(0 0 -100) :world :rotation-axis nil)
  (send *ri* :angle-vector (send *spotkinova* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (setq *spin* 0)
  (wait-for-target)
  (while (equal *spin* 0)
    (ros::spin-once))
  )
