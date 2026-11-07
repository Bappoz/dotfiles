.pragma library

// Top-anchored perspective rotation of the complete card, matching the
// Notch3DCardModifier parameters in OpenNotchi (MIT).
function matrix(width, progress, profile) {
  var p=Math.max(0,Math.min(1.16,progress));
  var angle=(profile.angle || 0)*(1-p)*Math.PI/180;
  var nx=1,ny=profile.axisY || 0,nz=profile.axisY ? .1 : 0;
  var magnitude=Math.sqrt(nx*nx+ny*ny+nz*nz);nx/=magnitude;ny/=magnitude;nz/=magnitude;
  var c=Math.cos(angle),s=Math.sin(angle),v=1-c;
  var a=c+nx*nx*v,b=nx*ny*v-nz*s,d=nx*ny*v+nz*s,e=c+ny*ny*v;
  var g=nz*nx*v-ny*s,h=nz*ny*v+nx*s;
  var scale=profile.scale+(1-profile.scale)*p;
  var cx=width/2,depth=900;
  var m41=-scale*g/depth,m42=-scale*h/depth,m44=1+scale*g*cx/depth;
  return Qt.matrix4x4(scale*a+cx*m41,scale*b+cx*m42,0,-scale*a*cx+cx*m44,
                     scale*d,scale*e,0,-scale*d*cx+(profile.offset || 0)*(1-p),
                     0,0,1,0,
                     m41,m42,0,m44);
}
