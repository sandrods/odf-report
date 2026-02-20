import logoIcon from '@/images/odf-report-logo-v2.svg'
import logoFull from '@/images/odf-report-logo-full.svg'
import Image from 'next/image'

export function Logomark({ className, ...props }) {
  return (
    <Image
      src={logoIcon}
      alt=""
      aria-hidden="true"
      className={className}
      {...props}
    />
  )
}

export function Logo({ className, ...props }) {
  return (
    <Image
      src={logoFull}
      alt="ODF-Report"
      className={className}
      {...props}
    />
  )
}
