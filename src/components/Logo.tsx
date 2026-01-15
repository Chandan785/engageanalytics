import React from 'react';

interface LogoProps {
  size?: 'sm' | 'md' | 'lg';
  showText?: boolean;
  className?: string;
}

export const Logo = ({ size = 'md', showText = true, className = '' }: LogoProps) => {
  const sizeConfig = {
    sm: { width: 120, height: 32, iconScale: 0.15 },
    md: { width: 180, height: 48, iconScale: 0.22 },
    lg: { width: 240, height: 64, iconScale: 0.3 },
  };

  const { width, height, iconScale } = sizeConfig[size];
  const iconOnly = !showText;
  const iconWidth = iconOnly ? height : width;
  const iconHeight = height;

  return (
    <svg
      width={iconWidth}
      height={iconHeight}
      viewBox={iconOnly ? "0 0 220 220" : "0 0 860 220"}
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label="ENGAGE Analytics Logo"
      className={className}
    >
      {/* Icon Group */}
      <g transform={iconOnly ? "translate(10, 40)" : "translate(20, 40)"}>
        {/* Eye Outline */}
        <path
          d="M20 70 Q90 10 180 70 Q90 130 20 70 Z"
          fill="none"
          stroke="#0F2A44"
          strokeWidth="10"
          strokeLinecap="round"
          strokeLinejoin="round"
          className="dark:stroke-slate-200"
        />
        {/* Hexagonal Pupil */}
        <polygon
          points="90,45 110,55 110,75 90,85 70,75 70,55"
          fill="#2D9A95"
        />
        {/* Passive Bars (Left - Grey) */}
        <rect x="40" y="65" width="10" height="30" fill="#9AA3AA" />
        <rect x="55" y="55" width="10" height="40" fill="#9AA3AA" />
        {/* Active Bars (Right - Teal) */}
        <rect x="115" y="70" width="10" height="25" fill="#2D9A95" />
        <rect x="130" y="55" width="10" height="40" fill="#2D9A95" />
        <rect x="145" y="40" width="10" height="55" fill="#2D9A95" />
        {/* Audio Waveform */}
        <g transform="translate(175, 70)">
          <line x1="0" y1="15" x2="0" y2="35" stroke="#2D9A95" strokeWidth="6" strokeLinecap="round" />
          <line x1="12" y1="5" x2="12" y2="45" stroke="#2D9A95" strokeWidth="6" strokeLinecap="round" />
          <line x1="24" y1="15" x2="24" y2="35" stroke="#2D9A95" strokeWidth="6" strokeLinecap="round" />
        </g>
      </g>

      {/* Text Group - Only shown when showText is true */}
      {showText && (
        <g transform="translate(260, 78)">
          {/* ENGAGE */}
          <text
            x="0"
            y="0"
            fill="#0F2A44"
            fontSize="56"
            fontWeight="700"
            fontFamily="Inter, Montserrat, Arial, sans-serif"
            letterSpacing="1"
            className="dark:fill-slate-100"
          >
            ENGAGE
          </text>
          {/* Analytics */}
          <text
            x="0"
            y="54"
            fill="#2D9A95"
            fontSize="40"
            fontWeight="500"
            fontFamily="Inter, Montserrat, Arial, sans-serif"
            letterSpacing="6.2"
          >
            Analytics
          </text>
        </g>
      )}
    </svg>
  );
};

export default Logo;
