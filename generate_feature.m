function [feat] = generate_feature(I)

Igray = rgb2gray(I);

% define xx, yy, theta
x = -2:1:2;
[xx, yy] = meshgrid(x, x);
theta = 0:pi/4:7*pi/4;

% define the basis filters and coefficients
G2a = 0.9213.*(2.*xx.^2 - 1).*exp(-(xx.^2 + yy.^2));
G2b = 1.843.*xx.*yy.*exp(-(xx.^2 + yy.^2));
G2c = 0.9213.*(2.*yy.^2 - 1).*exp(-(xx.^2 + yy.^2));

Gka = cos(theta).^2;
Gkb = -2.*cos(theta).*sin(theta);
Gkc = sin(theta).^2;

H2a = 0.9780.*(-2.254.*xx + xx.^3).*exp(-(xx.^2 + yy.^2));
H2b = 0.9780.*(-0.7515 + xx.^2).*yy.*exp(-(xx.^2 + yy.^2));
H2c = 0.9780.*(-0.7515 + yy.^2).*xx.*exp(-(xx.^2 + yy.^2));
H2d = 0.9780.*(-2.254.*yy + yy.^3).*exp(-(xx.^2 + yy.^2));

Hka = cos(theta).^3;
Hkb = -3.*cos(theta).^2.*sin(theta);
Hkc = 3.*cos(theta).*sin(theta).^2;
Hkd = -sin(theta).^3;

% now assemble the steerable filters and apply to image
Ifilt = cell(16, 1);
for i = 1:length(theta)
    G = Gka(i)*G2a + Gkb(i)*G2b + Gkc(i)*G2c;
    H = Hka(i)*H2a + Hkb(i)*H2b + Hkc(i)*H2c + Hkd(i)*H2d;
    Ifilt{i} = imfilter(Igray, G, 'replicate');
    Ifilt{8+i} = imfilter(Igray, H, 'replicate');
end

% apply pooling
feat = pool_feature(Ifilt);
end
