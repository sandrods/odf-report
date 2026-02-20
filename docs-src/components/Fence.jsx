'use client'

import { Fragment } from 'react'
import { Highlight, Prism } from 'prism-react-renderer'

;(typeof global !== 'undefined' ? global : window).Prism = Prism
require('prismjs/components/prism-ruby')

export function Fence({ children, language }) {
  return (
    <Highlight
      code={children.trimEnd()}
      language={language || 'text'}
      theme={{ plain: {}, styles: [] }}
    >
      {({ className, style, tokens, getTokenProps }) => (
        <pre className={className} style={style}>
          <code>
            {tokens.map((line, lineIndex) => (
              <Fragment key={lineIndex}>
                {line
                  .filter((token) => !token.empty)
                  .map((token, tokenIndex) => (
                    <span key={tokenIndex} {...getTokenProps({ token })} />
                  ))}
                {'\n'}
              </Fragment>
            ))}
          </code>
        </pre>
      )}
    </Highlight>
  )
}
