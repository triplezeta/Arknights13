import { AnimatedNumber, Box } from '../../components';

export const BeakerContents = props => {
  const { beakerLoaded, beakerContents } = props;
  return (
    <Box>
      {!beakerLoaded && (
        <Box color="label">
          No beaker loaded.
        </Box>
      ) || beakerContents.length === 0 && (
        <Box color="label">
          Beaker is empty.
        </Box>
      )}
      {beakerContents.map(chemical => (
        <Box key={chemical.name} color="label">
          <AnimatedNumber
            initial={0}
            duration={2000}
            value={chemical.volume} /> 
          {" units of "+chemical.name}
        </Box>
      ))}
    </Box>
  );
};
