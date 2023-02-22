export const resizePicture = () => {
  let scale = 1;
  const windowWidth = document.documentElement.clientWidth;
  const windowHeight = document.documentElement.clientHeight;

  if (windowWidth <= 360 && windowHeight <= 640) {
    scale = 0.15;
  } else if (windowWidth <= 440 && windowHeight <= 900) {
    scale = 0.33;
  } else if (windowWidth <= 680 && windowHeight <= 900) {
    scale = 0.5;
  } else if (windowWidth <= 1366 && windowHeight <= 768) {
    scale = 0.75;
  } else if (windowWidth <= 1536 && windowHeight <= 864) {
    scale = 0.82;
  } else if (windowWidth <= 1920 && windowHeight <= 1080) {
    scale = 0.85;
  }
  
  return scale;
};
