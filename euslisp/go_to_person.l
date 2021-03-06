#!/usr/bin/env roseus

(defvar *base-frame-id* "/base_link")

(load "package://spotkinovaeus/spotkinova-interface.l")
(load "utils.l")
(ros::roseus "person_approach_node")


(defun approach-to-person (target-bbox)
  (print "a")
  ;; get target object in world coords from bounding box of target 
  (setq *target-obj* (bounding-box->camera-frame-cube target-bbox))
  (send *target-obj* :translate #f(-500 0 0))
  (setq worldpos (scale 0.001 (send *target-obj* :worldpos)))
  (print "b")
  (setq x (elt worldpos 0))
  (setq y (elt worldpos 1))
  (print x)
  (print y)
  (send *ri* :angle-vector(send *spotkinova* :kinova-rest-pose) 5000)
  (send *ri* :wait-interpolation)
  (setq x (- x 0.3))
  (send *ri* :go-pos x y)
  (send *ri* :wait-interpolation)
  (setq *spin* 1)
  )

(defclass bba-class-synchronizer
    :super exact-time-message-filter)

(defmethod bba-class-synchronizer
    (:callback (msg-class msg-bba)
     (print "bba-class-synchronizer called")
     (let (target-boxes
	   target-bbox)
       (dotimes (i (length (send msg-class :labels)))
	 (let ((index (elt (send msg-class :labels) i)))
	   (when (= index 0)
	     (setq target-boxes (append target-boxes (list (elt (send msg-bba :boxes) i)))))
	   ))
       (print target-boxes)       
       (when (> (length target-boxes) 0)
	 (sort target-boxes #'(lambda (a b) (< (send a :pose :position :z)
					       (send b :pose :position :z))))
	 (setq target-bbox (car target-boxes))
	 (print target-bbox)
	 (approach-to-person target-bbox)
	 ))))
       

(defun move-to-person ()
  (send *ri* :angle-vector (send *spotkinova* :reset-pose) 5000)
  (send *ri* :wait-interpolation)
  (send *spotkinova* :head-elbow-y :joint-angle 0)
  (send *spotkinova* :head-wrist-p :joint-angle 180)
  (send *ri* :angle-vector (send *spotkinova* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (setq *spin* 0)
  (setq synchronizer (instance bba-class-synchronizer :init
                               (list (list "/edgetpu_object_detector/output/class" jsk_recognition_msgs::ClassificationResult)
                                     (list "/segmentation_decomposer_ssd/boxes" jsk_recognition_msgs::BoundingBoxArray))))
  (while (equal *spin* 0)
         (ros::spin-once))
  )


(defun bba-test ()
  (setq *spin* 0)
  (setq synchronizer (instance bba-class-synchronizer :init
                               (list (list "/edgetpu_object_detector/output/class" jsk_recognition_msgs::ClassificationResult)
                                     (list "/segmentation_decomposer_ssd/boxes" jsk_recognition_msgs::BoundingBoxArray))))
  (while (equal *spin* 0)
         (ros::spin-once))
  )

