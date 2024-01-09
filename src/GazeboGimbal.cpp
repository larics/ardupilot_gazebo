#include "GazeboGimbal.h"

namespace gazebo {

enum {
  ROLL,
  PITCH,
  YAW,
};

GazeboGimbal::GazeboGimbal() {}

GazeboGimbal::~GazeboGimbal() {}

void GazeboGimbal::Load(physics::ModelPtr _model, sdf::ElementPtr _sdf)
{

  if (!ros::isInitialized()) {
    ROS_FATAL_STREAM("Cannot load Gimbal plugin, ROS node for Gazebo not initialized");
    return;
    int argc = 0;
    char **argv = NULL;
    ros::init(argc, argv, "gimbal_controller", ros::init_options::NoSigintHandler);
  }

  node_handle_ = std::make_unique<ros::NodeHandle>("gimbal_controller");

  // Create a named topic, and subscribe to it.
  auto sub_options = ros::SubscribeOptions::create<geometry_msgs::Vector3Stamped>(
    "/" + _model->GetName() + "/gimbal/euler_ref",
    1,
    boost::bind(&GazeboGimbal::control_callback, this, _1),
    ros::VoidPtr(),
    &callback_queue_);
  control_sub_ = node_handle_->subscribe(sub_options);

  if (!_sdf->HasElement("namespace")) {
    ROS_FATAL("[GazeboGimbal] Namespace argument not provded");
    namespace_ = "error";
  } else {
    namespace_ = _sdf->Get<std::string>("namespace");
  }

  joints_.resize(3);
  joints_[ROLL] = _model->GetJoint(namespace_ + "/gimbal_roll_joint");
  joints_[PITCH] = _model->GetJoint(namespace_ + "/gimbal_pitch_joint");
  joints_[YAW] = _model->GetJoint(namespace_ + "/gimbal_yaw_joint");
  count = 0;

  link = _model->GetLink(namespace_ + "/gimbal_link_1");
  world = _model;
  updateConnection_ =
    event::Events::ConnectWorldUpdateBegin(boost::bind(&GazeboGimbal::Update, this));

  // Start the ROS queue thread
  ros_queue_thread_ = std::thread(std::bind(&GazeboGimbal::ros_queue, this));
}

void GazeboGimbal::control_callback(const geometry_msgs::Vector3StampedConstPtr &msg)
{
  control_input_ = *msg;
}

void GazeboGimbal::ros_queue()
{
  static constexpr auto timeout = 0.01;
  while (node_handle_->ok()) {
    callback_queue_.callAvailable(ros::WallDuration(timeout));
  }
}

void GazeboGimbal::Update()
{
  ignition::math::Pose3d pose = link->WorldPose();

  double x, y, z, w;
  x = pose.Rot().X();
  y = pose.Rot().Y();
  z = pose.Rot().Z();
  w = pose.Rot().W();

  double pitch_c = M_PI / 2 - std::acos(2 * x * z - 2 * y * w);
  double roll_c = std::acos(2 * y * z + 2 * x * w) - M_PI / 2;

  joints_[YAW]->SetPosition(0, 0);
  joints_[PITCH]->SetPosition(0, pitch_c + control_input_.vector.y);
  joints_[ROLL]->SetPosition(0, roll_c + control_input_.vector.x);
}

GZ_REGISTER_MODEL_PLUGIN(GazeboGimbal);
}// namespace gazebo
