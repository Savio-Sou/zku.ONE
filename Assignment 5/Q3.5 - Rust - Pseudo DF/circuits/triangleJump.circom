pragma circom 2.0.3;

include "node_modules/circomlib/circuits/comparators.circom";
include "node_modules/circomlib/circuits/pointbits.circom";

template triangleJump(maxDist) {  
    signal input Ax;
    signal input Ay;
    signal input Bx;
    signal input By;
    signal input Cx;
    signal input Cy;
    signal output valid;

    // Triangle check
    // Check x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2) != 0
    component comp = IsZero();
    signal part1;
    signal part2;
    signal part3;
    part1 <== Ax * (By - Cy);
    part2 <== Bx * (Cy - Ay);
    part3 <== Cx * (Ay - By);
    comp.in <== part1 + part2 + part3;
    comp.out === 0;

    // Distance check
    // Check (x1-x2)^2 + (y1-y2)^2 <= maxDist^2
    signal diffX[3];
    signal diffY[3];
    signal firstDistSquare[3];
    signal secondDistSquare[3];
    component letDist[3];

    // A -> B
    diffX[0] <== Ax - Bx;
    diffY[0] <== Ay - By;
    // B -> C
    diffX[1] <== Bx - Cx;
    diffY[1] <== By - Cy;
    // C -> A
    diffX[2] <== Cx - Ax;
    diffY[2] <== Cy - Ay;

    for (var i = 0; i < 3; i++) {
        letDist[i] = LessEqThan(64);
        firstDistSquare[i] <== diffX[i] * diffX[i];
        secondDistSquare[i] <== diffY[i] * diffY[i];
        letDist[i].in[0] <== firstDistSquare[i] + secondDistSquare[i];
        letDist[i].in[1] <== maxDist * maxDist + 1;
        letDist[i].out === 1;
    }

    // Output valid if all above constraints pass
    valid <== 1;
}

component main = triangleJump(10);