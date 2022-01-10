#!/usr/bin/env roseus

;;(defvar *base-frame-id* "/base_link")　;; To do: change this

(load "package://spotkinovaeus/spotkinova-interface.l")

(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "geometry_msgs")

(ros::roseus "object_approach_node")

(defun bounding-box->cube (msg)
  (let (;; rosのgeometry_msgs/Poseという型をもとに，Euslispのcoordsに変換
        (cds (ros::tf-pose->coords (send msg :pose)))
	(print "cds")
	(print cds)
        ;; BoundingBoxのdimentions(幅・奥行き・高さ)を取得
        (d (vector3-> 'list (send msg :dimensions)))
	(print "d")
	(print d)
	;; make-cubeの単位をmにする
	(setq *new_d* ())
	(dolist (i (d))
	  (setq a (/ i 1000))
	  (push a *new_d*))
        ;; *base-frame-id*相対の座標系に変換
        (base->parent (send *tfl* :lookup-transform
                            *base-frame-id* (send msg :header :frame_id)
                            (ros::time 0))))
    ;; :copy-worldcoords 最初にワールド座標系が計算されdestにコピーされる
    (send *tfb* :send-transform
          (send (send base->parent :copy-worldcoords)
                :transform cds
                *base-frame-id* "target_object" (send msg :header :stamp))
    ;; Euslisp内部でのworld座標系の値にして、そこにmake-cubeの箱を設置する
    (send (apply #'make-cube *new_d*)
          :transform
          (send (send base->parent :copy-worldcoords)
                :transform cds)))))
  
(defun move-callback (msg)
  (unless msg
    (publish-info "target box is nil")
    (return-from move-callback nil))
  ;; BoundingBoxArrayのリストの先頭のBoxからworld座標系のtarget objectを取得
  (setq *target-obj* (bounding-box->cube (elt (send msg :boxes) 0)))
  ;; :worldpos
  (setq *obj-pos* (send *target-obj* :worldpos))
  (*obj-pos*)
  ;;(send *ri* go-pos (send *target-obj* :worldpos)))　;; To do: change this


(defun wait-for-target ()
  (ros::subscribe "/kinova_wrist_camera/depth/color/boxes"
                  jsk_recognition_msgs::BoundingBoxArray #'move-callback))

(defun demo ()
  (setq *tfl* (instance ros::transform-listener :init))
  (setq *tfb* (instance ros::transform-broadcaster :init))
  ;(wait-for-target)
  (ros::spin))
