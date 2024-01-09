#ifndef GAZEBO_GIMBAL_H
#define GAZEBO_GIMBAL_H

#include <gazebo/gazebo.hh>
#include <gazebo/physics/physics.hh>

#include <ros/callback_queue.h>
#include <ros/ros.h>

#include <geometry_msgs/Vector3Stamped.h>

namespace gazebo {


class GazeboGimbal : public ModelPlugin
{
public:
  GazeboGimbal();
  ~GazeboGimbal();
  void Load(physics::ModelPtr parent, sdf::ElementPtr sdf);

protected:
  virtual void Update();

private:
  std::string namespace_;

  /* ROS stuff */
  std::unique_ptr<ros::NodeHandle> node_handle_;

  // Control input subscriber + Callback queue
  ros::CallbackQueue callback_queue_;
  ros::Subscriber control_sub_;
  geometry_msgs::Vector3Stamped control_input_;
  void control_callback(const geometry_msgs::Vector3StampedConstPtr &msg);

  // ROS callback queue processing
  std::thread ros_queue_thread_;
  void ros_queue();

  std::vector<physics::JointPtr> joints_;
  physics::LinkPtr link;
  physics::ModelPtr world;
  event::ConnectionPtr updateConnection_;
  int count;
};
}// namespace gazebo

#endif// GAZEBO_GIMBAL_H
