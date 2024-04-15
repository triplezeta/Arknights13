import { DmIcon, Icon, Image } from '../../components';
import { SearchItem } from './types';

type Props = {
  item: SearchItem;
};

export function IconDisplay(props: Props) {
  const {
    item: { icon, icon_state },
  } = props;

  const fallback = <Icon name="spinner" size={2.4} spin color="gray" />;

  if (!icon) {
    return fallback;
  }

  if (icon_state) {
    return <DmIcon fallback={fallback} icon={icon} icon_state={icon_state} />;
  }

  return <Image fixErrors src={icon} />;
}
