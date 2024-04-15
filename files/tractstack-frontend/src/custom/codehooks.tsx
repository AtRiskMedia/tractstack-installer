const CodeHook = ({ target }: { target: string }) => {
  switch (target) {
    //case `Branding`:
    //  return <Branding />

    default:
      console.log(`missed on`, target)
      return <div />
  }
}

export default CodeHook;
