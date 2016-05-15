columns = [
    propertyName: "playerNumber"
    title:        "Player #"
  ,
    propertyName: "playerTeam"
    title:        "Player Team"
  ,
    propertyName: "sessionName"
    title:        "Session"
  ,
    propertyName: "twoPointAttempt.count"
    title:        "2 Pt. A"
    template:     "cells/two-point-attempt"
  ,
    propertyName: "twoPointMade.count"
    title:        "2 Pt. M"
    template:     "cells/two-point-made"
  ,
    propertyName: "threePointAttempt.count"
    title:        "3 Pt. A"
    template:     "cells/three-point-attempt"
  ,
    propertyName: "threePointMade.count"
    title:        "3 Pt. M"
    template:     "cells/three-point-made"
  ,
    propertyName: "freeThrowAttempt.count"
    title:        "FT A"
    template:     "cells/free-throw-attempt"
  ,
    propertyName: "freeThrowMade.count"
    title:        "FT M"
    template:     "cells/free-throw-made"
  ,
    propertyName: "assist.count"
    title:        "Assist"
    template:     "cells/assist"
  ,
    propertyName: "foul.count"
    title:        "Foul"
    template:     "cells/foul"
  ,
    propertyName: "rebound.count"
    title:        "Rebound"
    template:     "cells/rebound"
  ,
    propertyName: "turnover.count"
    title:        "T/O"
    template:     "cells/turnover"
  ,
    propertyName: "steal.count"
    title:        "Steal"
    template:     "cells/steal"
]

customClasses =
  table: "table-info text-warning"

`export { columns, customClasses }`
