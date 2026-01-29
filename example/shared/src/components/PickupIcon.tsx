import Svg, {
  Defs,
  Ellipse,
  FeBlend,
  FeColorMatrix,
  FeFlood,
  FeGaussianBlur,
  Filter,
  G,
  LinearGradient,
  Mask,
  Path,
  Rect,
  Stop,
} from 'react-native-svg';

interface PickupIconProps {
  loaded?: boolean;
}

export const PickupIcon = ({ loaded = false }: PickupIconProps) => {
  const bedColor = loaded ? '#4A90D9' : 'white';
  const bedOverlayOpacity = loaded ? 0.5 : 0.3;

  return (
    <Svg width={45} height={80} viewBox="0 0 45 80" fill="none">
      <Defs>
        <Filter
          id="filter0_ddd"
          x={5.1333}
          y={8}
          width={35}
          height={64}
          filterUnits="userSpaceOnUse"
        >
          <FeFlood floodOpacity={0} result="BackgroundImageFix" />
          <FeColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
            result="hardAlpha"
          />
          <FeGaussianBlur stdDeviation={3} />
          <FeColorMatrix
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.3 0"
          />
          <FeBlend
            mode="normal"
            in2="BackgroundImageFix"
            result="effect1_dropShadow"
          />
          <FeColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
            result="hardAlpha"
          />
          <FeGaussianBlur stdDeviation={1} />
          <FeColorMatrix
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0"
          />
          <FeBlend
            mode="normal"
            in2="effect1_dropShadow"
            result="effect2_dropShadow"
          />
          <FeColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
            result="hardAlpha"
          />
          <FeGaussianBlur stdDeviation={0.5} />
          <FeColorMatrix
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0"
          />
          <FeBlend
            mode="normal"
            in2="effect2_dropShadow"
            result="effect3_dropShadow"
          />
          <FeBlend
            mode="normal"
            in="SourceGraphic"
            in2="effect3_dropShadow"
            result="shape"
          />
        </Filter>
        <Filter
          id="filter1_f"
          x={29.6732}
          y={12.7276}
          width={7.6014}
          height={7.85653}
          filterUnits="userSpaceOnUse"
        >
          <FeFlood floodOpacity={0} result="BackgroundImageFix" />
          <FeBlend
            mode="normal"
            in="SourceGraphic"
            in2="BackgroundImageFix"
            result="shape"
          />
          <FeGaussianBlur
            stdDeviation={1.22323}
            result="effect1_foregroundBlur"
          />
        </Filter>
        <Filter
          id="filter5_f"
          x={8.27376}
          y={12.7276}
          width={7.6014}
          height={7.85653}
          filterUnits="userSpaceOnUse"
        >
          <FeFlood floodOpacity={0} result="BackgroundImageFix" />
          <FeBlend
            mode="normal"
            in="SourceGraphic"
            in2="BackgroundImageFix"
            result="shape"
          />
          <FeGaussianBlur
            stdDeviation={1.22323}
            result="effect1_foregroundBlur"
          />
        </Filter>
        <LinearGradient
          id="paint0_linear"
          x1={34.1333}
          y1={38}
          x2={34.1333}
          y2={30}
          gradientUnits="userSpaceOnUse"
        >
          <Stop stopColor="#FEFEFE" stopOpacity={0.01} />
          <Stop offset={0.499765} stopColor="#D6D6D7" />
          <Stop offset={1} stopColor="#FEFEFE" stopOpacity={0.01} />
        </LinearGradient>
        <LinearGradient
          id="paint6_linear"
          x1={34.1333}
          y1={17}
          x2={34.1333}
          y2={10}
          gradientUnits="userSpaceOnUse"
        >
          <Stop stopColor="#FEFEFE" stopOpacity={0.01} />
          <Stop offset={0.499765} stopColor="#3A3A3A" />
          <Stop offset={1} stopColor="#FEFEFE" stopOpacity={0.01} />
        </LinearGradient>
        <LinearGradient
          id="paint17_linear"
          x1={50.7274}
          y1={49.6725}
          x2={35.5392}
          y2={49.6725}
          gradientUnits="userSpaceOnUse"
        >
          <Stop stopColor="#3E3E3E" />
          <Stop offset={1} stopColor="#000" />
        </LinearGradient>
        <LinearGradient
          id="paint24_linear"
          x1={13.5891}
          y1={24.0108}
          x2={13.5891}
          y2={31.6613}
          gradientUnits="userSpaceOnUse"
        >
          <Stop stopColor="#A4A4A4" />
          <Stop offset={1} stopColor="#3F3F3F" />
        </LinearGradient>
        <Mask
          id="mask0"
          maskUnits="userSpaceOnUse"
          x={11}
          y={14}
          width={24}
          height={52}
        >
          <Path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M33.1333 63V59.9146C33.7159 59.7087 34.1333 59.1531 34.1333 58.5V51.5C34.1333 50.8469 33.7159 50.2913 33.1333 50.0854V30.25L33.0643 28.4891C33.6701 28.0186 34.0468 27.2696 34.0053 26.4407L33.7429 21.191C33.7048 20.4305 33.3014 19.7712 32.7076 19.3797L32.6851 18.8043C32.58 16.1211 30.3742 14 27.6889 14L17.5777 14C14.8924 14 12.6866 16.1211 12.5815 18.8043L12.559 19.3797C11.9652 19.7712 11.5618 20.4305 11.5237 21.1911L11.2613 26.4407C11.2198 27.2696 11.5965 28.0186 12.2023 28.4891L12.1333 30.25L12.1333 50.0854C11.5507 50.2913 11.1333 50.8469 11.1333 51.5V58.5C11.1333 59.1531 11.5507 59.7087 12.1333 59.9146V63C12.1333 64.6569 13.4764 66 15.1333 66H30.1333C31.7902 66 33.1333 64.6569 33.1333 63Z"
            fill="white"
          />
        </Mask>
        <Mask
          id="mask1"
          maskUnits="userSpaceOnUse"
          x={27}
          y={12}
          width={7}
          height={6}
        >
          <Path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M33.0426 15.2197C33.2957 15.3994 33.4509 15.6864 33.4628 15.9966L33.4728 16.2561C33.5099 17.2232 32.229 17.7208 31.5335 17.0478C31.1643 16.6905 30.778 16.3484 30.4042 16.0713C30.1279 15.8664 29.8168 15.7147 29.5002 15.6027C28.3696 15.2025 27.3468 14.1955 27.484 13.004C27.5669 12.2838 28.3916 11.9162 28.9826 12.336L33.0426 15.2197Z"
            fill="white"
          />
        </Mask>
        <Mask
          id="mask3"
          maskUnits="userSpaceOnUse"
          x={12}
          y={12}
          width={7}
          height={6}
        >
          <Path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M12.5057 15.2197C12.2527 15.3994 12.0974 15.6864 12.0855 15.9966L12.0756 16.2561C12.0385 17.2232 13.3193 17.7208 14.0149 17.0478C14.384 16.6905 14.7704 16.3484 15.1442 16.0713C15.4205 15.8664 15.7315 15.7147 16.0481 15.6027C17.1788 15.2025 18.2015 14.1955 18.0643 13.004C17.9814 12.2838 17.1567 11.9162 16.5657 12.336L12.5057 15.2197Z"
            fill="white"
          />
        </Mask>
      </Defs>

      {/* Shadow and body */}
      <G filter="url(#filter0_ddd)">
        <Path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M33.1333 63V59.9146C33.7159 59.7087 34.1333 59.1531 34.1333 58.5V51.5C34.1333 50.8469 33.7159 50.2913 33.1333 50.0854V30.25L33.0643 28.4891C33.6701 28.0186 34.0468 27.2696 34.0053 26.4407L33.7429 21.191C33.7048 20.4305 33.3014 19.7712 32.7076 19.3797L32.6851 18.8043C32.58 16.1211 30.3742 14 27.6889 14L17.5777 14C14.8924 14 12.6866 16.1211 12.5815 18.8043L12.559 19.3797C11.9652 19.7712 11.5618 20.4305 11.5237 21.1911L11.2613 26.4407C11.2198 27.2696 11.5965 28.0186 12.2023 28.4891L12.1333 30.25L12.1333 50.0854C11.5507 50.2913 11.1333 50.8469 11.1333 51.5V58.5C11.1333 59.1531 11.5507 59.7087 12.1333 59.9146V63C12.1333 64.6569 13.4764 66 15.1333 66H30.1333C31.7902 66 33.1333 64.6569 33.1333 63Z"
          fill="black"
        />
      </G>

      <G mask="url(#mask0)">
        {/* White body fill */}
        <Path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M39.1333 6L39.1333 78H6.1333L6.1333 6L39.1333 6Z"
          fill="white"
        />

        {/* Bed shadow gradient */}
        <Path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M34.1333 30V38H11.1333V30H34.1333Z"
          fill="url(#paint0_linear)"
        />

        {/* Cab top shadow */}
        <Rect
          opacity={0.1}
          width={7}
          height={25}
          transform="matrix(0 -1 -1 0 35.1333 33)"
          fill="black"
        />

        {/* Cab windshield area */}
        <Path
          opacity={0.3}
          fillRule="evenodd"
          clipRule="evenodd"
          d="M30.1333 33H15.1333L22.5587 32L30.1333 33Z"
          fill="black"
        />

        {/* Side details */}
        <Rect
          opacity={0.4}
          width={1}
          height={2}
          transform="matrix(0 -1 -1 0 33.1333 33.5)"
          fill="black"
        />
        <Rect
          opacity={0.4}
          width={1}
          height={2}
          transform="matrix(0 -1 -1 0 14.1333 33.5)"
          fill="black"
        />

        {/* Cab front gradient */}
        <Path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M34.1333 10V17H11.1333V10L34.1333 10Z"
          fill="url(#paint6_linear)"
        />

        {/* Front hood line */}
        <Path
          opacity={0.5}
          fillRule="evenodd"
          clipRule="evenodd"
          d="M30.1333 15H15.1333L22.5587 14L30.1333 15Z"
          fill="white"
        />

        {/* Right mirror */}
        <Path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M33.0426 15.2197C33.2957 15.3994 33.4509 15.6864 33.4628 15.9966L33.4728 16.2561C33.5099 17.2232 32.229 17.7208 31.5335 17.0478C31.1643 16.6905 30.778 16.3484 30.4042 16.0713C30.1279 15.8664 29.8168 15.7147 29.5002 15.6027C28.3696 15.2025 27.3468 14.1955 27.484 13.004C27.5669 12.2838 28.3916 11.9162 28.9826 12.336L33.0426 15.2197Z"
          fill="#1C1F34"
        />

        <G mask="url(#mask1)">
          <G filter="url(#filter1_f)">
            <Ellipse
              cx={33.4738}
              cy={16.6559}
              rx={1.5}
              ry={1.33333}
              transform="rotate(110 33.4738 16.6559)"
              fill="#FF871D"
            />
          </G>
        </G>

        {/* Left mirror */}
        <Path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M12.5057 15.2197C12.2527 15.3994 12.0974 15.6864 12.0855 15.9966L12.0756 16.2561C12.0385 17.2232 13.3193 17.7208 14.0149 17.0478C14.384 16.6905 14.7704 16.3484 15.1442 16.0713C15.4205 15.8664 15.7315 15.7147 16.0481 15.6027C17.1788 15.2025 18.2015 14.1955 18.0643 13.004C17.9814 12.2838 17.1567 11.9162 16.5657 12.336L12.5057 15.2197Z"
          fill="#1C1F34"
        />

        <G mask="url(#mask3)">
          <G filter="url(#filter5_f)">
            <Ellipse
              cx={12.0746}
              cy={16.6559}
              rx={1.5}
              ry={1.33333}
              transform="rotate(70 12.0746 16.6559)"
              fill="#FF871D"
            />
          </G>
        </G>

        {/* Truck bed */}
        <Rect
          x={31.1333}
          y={41}
          width={24}
          height={17}
          transform="rotate(90 31.1333 41)"
          fill="url(#paint17_linear)"
        />
        <Rect
          x={31.1333}
          y={41}
          width={24}
          height={17}
          transform="rotate(90 31.1333 41)"
          fill={bedColor}
          fillOpacity={bedOverlayOpacity}
        />

        {/* Bed slats */}
        <Path
          opacity={0.2}
          fillRule="evenodd"
          clipRule="evenodd"
          d="M28.1333 65V41H27.4666V65H28.1333ZM26.1333 65V41H25.4666V65H26.1333ZM24.1333 41V65H23.4666V41H24.1333ZM22.1333 65V41H21.4666V65H22.1333ZM20.1333 41V65H19.4666V41H20.1333ZM18.1333 65V41H17.4666V65H18.1333Z"
          fill="black"
        />

        {/* Bed top shadow */}
        <Rect
          opacity={0.1}
          x={31.1333}
          y={41}
          width={4.66667}
          height={16.6667}
          transform="rotate(90 31.1333 41)"
          fill="black"
        />

        {/* Side rails */}
        <Rect
          opacity={0.4}
          x={31.1333}
          y={41}
          width={25}
          height={1}
          transform="rotate(90 31.1333 41)"
          fill="black"
        />
        <Rect
          opacity={0.4}
          x={15.1333}
          y={41}
          width={25}
          height={1}
          transform="rotate(90 15.1333 41)"
          fill="black"
        />

        {/* Cab rear shadow */}
        <Path
          opacity={0.5}
          fillRule="evenodd"
          clipRule="evenodd"
          d="M14.1333 43H31.1333L33.1333 41.9748V41H12.1333V41.9748L14.1333 43Z"
          fill="black"
        />

        {/* Windshield */}
        <Path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M30.8443 23C31.3834 23 31.8254 23.4273 31.8438 23.966L32.0817 30.966C32.1009 31.5313 31.6479 32 31.0823 32H14.1844C13.6188 32 13.1658 31.5313 13.185 30.966L13.4229 23.966C13.4412 23.4273 13.8833 23 14.4224 23H30.8443Z"
          fill="black"
        />
        <Path
          opacity={0.6}
          fillRule="evenodd"
          clipRule="evenodd"
          d="M30.8484 24C31.3858 24 31.8272 24.4248 31.8477 24.9618L32.0771 30.9618C32.0988 31.5286 31.6451 32 31.0779 32H14.1888C13.6215 32 13.1679 31.5286 13.1896 30.9618L13.419 24.9618C13.4395 24.4248 13.8808 24 14.4183 24H30.8484Z"
          fill="url(#paint24_linear)"
        />
      </G>

      {/* Antenna bumps */}
      <Rect
        x={35}
        y={26.196}
        width={1.33333}
        height={4}
        rx={0.666667}
        transform="rotate(105 35 26.196)"
        fill="black"
      />
      <Rect
        width={1.33333}
        height={4}
        rx={0.666667}
        transform="matrix(0.258819 0.965926 0.965926 -0.258819 10.1714 26.196)"
        fill="black"
      />
    </Svg>
  );
};
