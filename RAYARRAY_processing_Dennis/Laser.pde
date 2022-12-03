class Laser {
    Ray mRay;

    Laser() {
        mRay = new Ray();
        position().x = 0;
        position().y = 0;
        direction().x = 1;
        direction().y = 0;
    }

    //set laser diode's position
    PVector position() {
        return mRay.origin;
    }

    PVector direction() {
        return mRay.direction;
    }
    
    //draw the origin of the laser diode
    void drawOrigin() {
        noStroke();
        fill(255);
        circle(position().x, position().y, 10);
    }

    //draw all the rays emitting from that diode
    void drawRays() {
        mRay.update();
        mRay.draw();
        strokeWeight(1);
        final float mRayLength = 40;
        line(
        position().x,
        position().y,
        position().x + direction().x * mRayLength,
        position().y + direction().y * mRayLength
        );
    }
}
