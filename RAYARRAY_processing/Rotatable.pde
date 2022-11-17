interface Rotatable extends Renderable {
  void set_rotation(float rotation);
  void set_rotation_offset(float rotationOffset);
  float get_rotation();
  float get_rotation_offset();
  void set_rotation_speed(float rotationSpeed);
  void set_rotation_direction(boolean rotationDirection);
  void update(float pDelta);
}